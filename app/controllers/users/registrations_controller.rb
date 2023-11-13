class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix
  respond_to :json

  before_action :configure_sign_up_params, only: [:create]

  private

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password])
  end

  def respond_with(current_user, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'User created successfully.' },
        data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: {
          code: 422,
          message: "User couldn't be created successfully. #{current_user.errors.full_messages.to_sentence}"
        }
      }, status: :unprocessable_entity
    end
  end
end
