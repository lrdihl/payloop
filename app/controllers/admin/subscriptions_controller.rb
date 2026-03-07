module Admin
  class SubscriptionsController < BaseController
    include Dry::Monads[:result]

    layout "admin"

    before_action :set_subscription, only: %i[show activate fail retry cancel close update_payment_method]

    def index
      authorize Subscription
      @subscriptions = policy_scope(Subscription).includes(:user, :plan).order(created_at: :desc)
    end

    def show
      authorize @subscription
    end

    def new
      authorize Subscription
      @subscription = Subscription.new
    end

    def create
      authorize Subscription

      result = Subscriptions::Operations::CreateSubscription.new.call(subscription_params)

      handle_result(result) do |subscription|
        redirect_to admin_subscription_path(subscription), notice: "Assinatura criada com sucesso."
      end
    end

    def activate
      authorize @subscription, :activate?
      handle_transition(Subscriptions::Operations::ActivateSubscription.new.call(@subscription))
    end

    def fail
      authorize @subscription, :fail?
      handle_transition(Subscriptions::Operations::FailSubscription.new.call(@subscription))
    end

    def retry
      authorize @subscription, :retry?
      handle_transition(Subscriptions::Operations::RetrySubscription.new.call(@subscription))
    end

    def cancel
      authorize @subscription, :cancel?
      handle_transition(Subscriptions::Operations::CancelSubscription.new.call(@subscription))
    end

    def close
      authorize @subscription, :close?
      handle_transition(Subscriptions::Operations::CloseSubscription.new.call(@subscription))
    end

    def update_payment_method
      authorize @subscription, :update_payment_method?

      result = Subscriptions::Operations::UpdatePaymentMethod.new.call(
        subscription: @subscription,
        payment_method: params.dig(:subscription, :payment_method)
      )

      handle_result(result) do |subscription|
        redirect_to admin_subscription_path(subscription), notice: "Método de pagamento atualizado."
      end
    end

    private

    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    def subscription_params
      params.require(:subscription)
            .permit(:user_id, :plan_id, :joined_at, :payment_method)
            .to_h
            .deep_symbolize_keys
    end

    def action_for_failure
      :new
    end

    def handle_transition(result)
      case result
      in Dry::Monads::Success(subscription)
        redirect_to admin_subscription_path(subscription), notice: "Assinatura atualizada."
      in Dry::Monads::Failure({ errors: errors })
        message = errors.values.flatten.first
        redirect_to admin_subscription_path(@subscription), alert: "Transição inválida: #{message}"
      end
    end
  end
end
