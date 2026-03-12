# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!

  # Captura violações de autorização do Pundit em qualquer controller
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

  private

  # Converte um Dry::Monads::Result em resposta HTTP.
  # Controllers não precisam saber nada sobre Success/Failure — apenas chamam isso.
  #
  # Uso:
  #   result = Identity::Operations::RegisterUser.new.call(params)
  #   handle_result(result) do |user|
  #     redirect_to dashboard_path
  #   end
  #
  def handle_result(result, &on_success)
    case result
    in Dry::Monads::Success(value)
      on_success.call(value)
    in Dry::Monads::Failure({ type: :validation, errors: errors })
      @errors = errors
      render_failure(:unprocessable_entity)
    in Dry::Monads::Failure({ type: :persistence, errors: errors })
      @errors = errors
      render_failure(:unprocessable_entity)
    in Dry::Monads::Failure({ type: :stale, errors: errors })
      @errors = errors
      render_failure(:conflict)
    in Dry::Monads::Failure(error)
      @errors = { base: [ error.to_s ] }
      render_failure(:unprocessable_entity)
    end
  end

  def render_failure(status)
    respond_to do |format|
      format.html { render action_for_failure, status: }
      format.json { render json: { errors: @errors }, status: }
    end
  end

  # Sobrescrito em cada controller que precise de comportamento diferente
  def action_for_failure
    :new
  end

  def handle_unauthorized
    respond_to do |format|
      format.html do
        flash[:alert] = t("flash.unauthorized")
        redirect_back fallback_location: "/"
      end
      format.json { render json: { error: "Não autorizado" }, status: :forbidden }
    end
  end
end
