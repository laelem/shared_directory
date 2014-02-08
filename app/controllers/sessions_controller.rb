class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.active? && user.authenticate(params[:password])
      sign_in user
      redirect_back_or root_path
    else
      if params[:email].blank? and params[:password].blank?
        flash.now[:error] = 'Email and password can\'t be blank'
      elsif params[:email].blank?
        flash.now[:error] = 'Email can\'t be blank'
      elsif params[:password].blank?
        flash.now[:error] = 'Password can\'t be blank'
      elsif !VALID_EMAIL_REGEX.match params[:email]
        flash.now[:error] = 'Email is invalid'
      elsif user && !user.active?
        flash.now[:error] = 'Your account is not active. Please contact an administrator.'
      else
        flash.now[:error] = 'Invalid email/password combination'
      end
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to signin_path
  end
end
