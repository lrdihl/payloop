module Customer
  class SubscriptionsController < ApplicationController
    include Dry::Monads[:result]

    layout "admin"

    before_action :require_customer!
    before_action :set_subscription, only: %i[cancel]

    def index
      authorize Subscription
      @subscriptions = policy_scope(Subscription).includes(:plan).order(created_at: :desc)
    end

    def new
      authorize Subscription

      if Subscription.current.exists?(user_id: current_user.id)
        redirect_to customer_subscriptions_path, notice: "Você já possui uma assinatura ativa ou pendente."
      else
        @subscription = Subscription.new
      end
    end

    def create
      authorize Subscription

      result = Subscriptions::Operations::CreateSubscription.new.call(
        user_id:   current_user.id,
        plan_id:   subscription_params[:plan_id],
        joined_at: Date.current
      )

      handle_result(result) do |_subscription|
        redirect_to customer_subscriptions_path, notice: "Assinatura criada com sucesso."
      end
    end

    def cancel
      authorize @subscription, :cancel?

      result = Subscriptions::Operations::CancelSubscription.new.call(@subscription)

      case result
      in Dry::Monads::Success(_)
        redirect_to customer_subscriptions_path, notice: "Assinatura cancelada."
      in Dry::Monads::Failure({ errors: errors })
        message = errors.values.flatten.first
        redirect_to customer_subscriptions_path, alert: "Transição inválida: #{message}"
      end
    end

    private

    def require_customer!
      unless current_user.customer?
        flash[:alert] = "Você não tem permissão para realizar esta ação."
        redirect_to root_path
      end
    end

    def set_subscription
      @subscription = current_user.subscriptions.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to customer_subscriptions_path, alert: "Assinatura não encontrada."
    end

    def subscription_params
      params.require(:subscription).permit(:plan_id).to_h.deep_symbolize_keys
    end

    def action_for_failure
      :new
    end
  end
end
