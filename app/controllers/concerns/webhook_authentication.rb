module WebhookAuthentication
  extend ActiveSupport::Concern

  included do
    class_attribute :authentication_config
  end

  class_methods do
    def authentication_through(method, param = nil)
      self.authentication_config = { method:, param: }.freeze
    end
  end

  def authenticate
    raise "Unable to define authentication method" if self.class.authentication_config.nil?

    method = self.class.authentication_config[:method]
    param  = self.class.authentication_config[:param]
    authenticate_through(method, param)
  end

  private

  def authenticate_through(method, param = nil)
    case method
    when :header_token             then authenticate_with_header_token(param)
    when :http_authentication_token then authenticate_with_http_authentication_token
    else raise "Invalid authentication method #{method}"
    end
  end

  def authenticate_with_http_authentication_token
    authenticate_with_header_token("X-Signature", /^(?:Token|Bearer)\s+(.+)/i)
  end

  def authenticate_with_header_token(header_name = "X-Signature", token_pattern = /(.+)/)
    authenticate_with_token(request.headers[header_name], token_pattern)
  end

  def authenticate_with_token(value, token_pattern = /(.+)/)
    match = token_pattern.match(value.to_s)
    return true if match && verify_token(match[1])

    render json: { status: :error, code: 401, messages: [ "Invalid Authentication Token" ] },
           status: :unauthorized
    false
  end

  def verify_token(token)
    @authentication_token = WebhookToken.find_for_authentication(controller_name, token)
    @authentication_token.present?
  end
end
