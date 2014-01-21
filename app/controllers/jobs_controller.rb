class JobsController < ApplicationController
  before_action :signed_in_user

  def index
    @jobs = Job.paginate(page: params[:page])
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
