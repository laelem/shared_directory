class UsersController < ApplicationController
  before_action :signed_in_user, :init_users_session
  before_action :find_user, only: [:edit, :update, :destroy, :toggle_status]
  before_action :current_user_access, only: [:destroy, :toggle_status]

  def index
    offset = session[:users][:per_page].to_i * params[:page].to_i
    if offset > User.count then params[:page] = "1" end

    @users = User.order("#{session[:users][:sort][:field]} #{session[:users][:sort][:type]}")\
      .paginate(per_page: session[:users][:per_page], page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params_new)
    if @user.save
      flash[:success] = "User saved successfully"
      redirect_to users_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params_edit)
      flash[:success] = "User updated successfully"
      redirect_to users_path
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted successfully"
    redirect_to users_path
  end

  def toggle_status
    @user.toggle!(:active)
    redirect_to users_path
  end

  def sort
    if session[:users][:sort][:field] != params[:field] or session[:users][:sort][:type] == 'desc'
    then sort_type = 'asc' else sort_type = 'desc' end
    session[:users][:sort] = { field: params[:field], type: sort_type }
    redirect_to users_path
  end

  def per_page
    params[:number] = user.count if params[:number] == "all"
    session[:users][:per_page] = params[:number].to_i
    redirect_to users_path
  end

  private

    def user_params_new
      params.require(:user).permit(:first_name, :last_name, :active, :admin, :email, :email_confirmation,
        :password, :password_confirmation)
    end

    def user_params_edit
      params.require(:user).permit(:first_name, :last_name, :active, :admin)
    end

    def init_users_session
      session[:users] ||= { sort: USERS_DEFAULT_SORT, per_page: USERS_DEFAULT_PER_PAGE }
    end

    def find_user
      @user = User.find(params[:id])
    end

    def current_user_access
      if current_user? @user then redirect_to not_found_path and return end
    end
end