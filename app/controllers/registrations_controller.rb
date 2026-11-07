class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :skip_authorization, only: %i[new create]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      WelcomeMailer.welcome(@user).deliver_later
      redirect_to root_path, notice: "Account created successfully."
    else
      @user.password = nil
      @user.password_confirmation = nil
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(
      :email_address,
      :password,
      :password_confirmation
    )
  end
end