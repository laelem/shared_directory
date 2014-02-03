class JobsController < ApplicationController
  before_action :signed_in_user, :init_jobs_session
  before_action :find_job, only: [:edit, :update, :destroy, :toggle_status]

  def index
    offset = session[:jobs][:per_page].to_i * params[:page].to_i
    if offset > Job.count then params[:page] = "1" end

    @jobs = Job.order("#{session[:jobs][:sort][:field]} #{session[:jobs][:sort][:type]}")\
      .paginate(per_page: session[:jobs][:per_page], page: params[:page])
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params)
    if @job.save
      flash[:success] = "Job saved successfully"
      redirect_to jobs_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @job.update_attributes(job_params)
      flash[:success] = "Job updated successfully"
      redirect_to jobs_path
    else
      render 'edit'
    end
  end

  def destroy
    @job.destroy
    flash[:success] = "Job deleted successfully"
    redirect_to jobs_path
  end

  def toggle_status
    @job.toggle!(:active)
    redirect_to jobs_path
  end

  def sort
    if session[:jobs][:sort][:field] != params[:field] or session[:jobs][:sort][:type] == 'desc'
    then sort_type = 'asc' else sort_type = 'desc' end
    session[:jobs][:sort] = { field: params[:field], type: sort_type }
    redirect_to jobs_path
  end

  def per_page
    params[:number] = Job.count if params[:number] == "all"
    session[:jobs][:per_page] = params[:number].to_i
    redirect_to jobs_path
  end

  private

    def job_params
      params.require(:job).permit(:name, :active)
    end

    def init_jobs_session
      session[:jobs] ||= { sort: JOBS_DEFAULT_SORT, per_page: JOBS_DEFAULT_PER_PAGE }
    end

    def find_job
      Job.find(params[:id])
    end
end
