module Webhooks
  class GatewayCallbacksController < ApplicationController
    include WebhookAuthentication

    skip_before_action :authenticate_user!
    skip_after_action  :verify_authorized, raise: false

    authentication_through :http_authentication_token
    before_action :authenticate

    def create
      result = Billing::Operations::HandleGatewayCallback.new.call(callback_params)

      case result
      in Dry::Monads::Success(payment)
        render json: { status: "ok", payment_id: payment.id }, status: :ok
      in Dry::Monads::Failure({ type: :not_found })
        render json: { error: "transaction_id não encontrado" }, status: :not_found
      in Dry::Monads::Failure({ type: :validation, errors: errors })
        render json: { errors: errors }, status: :unprocessable_entity
      in Dry::Monads::Failure(error)
        render json: { error: error.to_s }, status: :unprocessable_entity
      end
    end

    private

    def callback_params
      params.permit(:transaction_id, :status, gateway_response: {}).to_h.symbolize_keys
    end
  end
end
