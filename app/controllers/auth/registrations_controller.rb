class Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController
  private
  def sign_up_params
  params.permit(:unique_name, :display_name, :email, :password, :password_confirmation)
  end
 
  def account_update_params
  params.permit(:display_name, :description, :email)
  end
end
