class ContactsController < ApplicationController
  before_action :signed_in_user, :init_contacts_session
  before_action :find_contact, only: [:show, :edit, :update, :destroy, :toggle_status]
  before_action :select_data, only: [:new, :edit]
  before_action :admin_user, only: [:new, :create, :edit, :update, :destroy, :toggle_status]

  def index
    offset = session[:contacts][:per_page].to_i * params[:page].to_i
    if offset > Contact.count then params[:page] = "1" end

    @contacts = Contact\
      .where(session[:contacts][:filter].values.map{|v| v[:request]}.join(' AND '))\
      .order(session[:contacts][:sort][:field]+' '+session[:contacts][:sort][:type])\
      .paginate(per_page: session[:contacts][:per_page], page: params[:page])
  end

  def show
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      flash[:success] = "Contact saved successfully"
      redirect_to contacts_path
    else
      select_data
      render 'new'
    end
  end

  def edit
  end

  def update
    if @contact.update_attributes(contact_params)
      flash[:success] = "Contact updated successfully"
      redirect_to contacts_path
    else
      select_data
      render 'edit'
    end
  end

  def destroy
    @contact.destroy
    flash[:success] = "Contact deleted successfully"
    redirect_to contacts_path
  end

  def toggle_status
    @contact.toggle!(:active)
    redirect_to contacts_path
  end

  def sort
    if session[:contacts][:sort][:field] != params[:field] or session[:contacts][:sort][:type] == 'desc'
    then sort_type = 'asc' else sort_type = 'desc' end
    session[:contacts][:sort] = { field: params[:field], type: sort_type }
    redirect_to contacts_path
  end

  def per_page
    params[:number] = Contact.count if params[:number] == "all"
    session[:contacts][:per_page] = params[:number].to_i
    redirect_to contacts_path
  end

  def filter
    params = filter_params
    case
    when params[:active]
      if params[:active] == "Yes"
        session[:contacts][:filter][:active] = {request: "active = true", value: params[:active]}
      elsif params[:active] == "No"
        session[:contacts][:filter][:active] = {request: "active = false", value: params[:active]}
      else
        session[:contacts][:filter].delete :active
      end
    when params[:last_name]
      if ('A'..'Z').include? params[:last_name]
        session[:contacts][:filter][:last_name] = {request: "last_name LIKE '#{params[:last_name]}%'",
          value: params[:last_name]}
      else
        session[:contacts][:filter].delete :last_name
      end
    when (params[:email] and !params[:email_value].blank?)
      if params[:email] == 'OK'
        req = 'email ILIKE ' + ActiveRecord::Base::sanitize("%#{params[:email_value]}%")
        session[:contacts][:filter][:email] = {request: req, value: params[:email_value]}
      else
        session[:contacts][:filter].delete :email
      end
    when params[:reset]
      session[:contacts][:filter] = {}
    end

    redirect_to contacts_path
  end

  private

    def contact_params
      params.require(:contact).permit(:active, :civility, :first_name, :last_name, :date_of_birth,
        :address, :zip_code, :city, :country_id, :phone_number, :mobile_number,
        { job_ids: [] }, :email, :upload_photo, :website, :comment)
    end

    def filter_params
      params.require(:filter).permit(:active, :last_name, :email_value, :email, :reset)
    end

    def init_contacts_session
      session[:contacts] ||= { sort: CONTACTS_DEFAULT_SORT,
                               per_page: CONTACTS_DEFAULT_PER_PAGE,
                               filter: {} }
    end

    def find_contact
      @contact = Contact.find(params[:id])
    end

    def select_data
      @countries = Country.order("name = 'France' desc").order("name asc")
      @jobs = Job.where("active = true").order("name asc")
    end
end