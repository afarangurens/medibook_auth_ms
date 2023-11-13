class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  respond_to :json

  def create
    ldap = Net::LDAP.new
    ldap.host = '146.148.102.203' 
    ldap.port = 389
    ldap.auth "cn=admin,dc=arqsoft,dc=unal,dc=edu,dc=co", "admin"
    
    user_email = params[:user][:email]
    user_password = params[:user][:password]

    if ldap.bind_as(
        base: 'dc=arqsoft,dc=unal,dc=edu,dc=co',
        filter: "(cn=#{user_email})",
        password: user_password
      )
      # LDAP authentication successful
      user = User.find_or_create_by(username: user_email) do |u|
        u.email = user_email
        u.password = params[:user][:password]
      end

      sign_in(:user, user)

      token = generate_jwt_token(user)
      render json: {
        status: {
          code: 200,
          message: 'Logged in successfully.',
          data: {
            user: UserSerializer.new(user).serializable_hash[:data][:attributes],
            token: token
          }
        }
      }, status: :ok
    else
      # LDAP authentication failed
      render json: {
        status: {
          code: 401,
          message: 'Invalid username or password.'
        }
      }, status: :unauthorized
    end
  end

  def destroy
    sign_out(current_user) if user_signed_in?
    render json: {
      status: {
        code: 200,
        message: 'Logged out successfully.'
      }
    }, status: :ok
  end

  private

  def generate_jwt_token(user)
    payload = {
      sub: user.id,
      exp: Time.now.to_i + 24.hours.to_i
    }
    JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key)
  end
end
