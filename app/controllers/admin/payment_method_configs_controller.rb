module Admin
  class PaymentMethodConfigsController < BaseController
    layout "admin"

    def index
      authorize PaymentMethodConfig
      @configs = PaymentMethodConfig.all.index_by { |c| c.key.to_sym }
      @methods = Shared::PaymentMethods::Registry.all.except(:manual)
    end

    def toggle
      @config = PaymentMethodConfig.find(params[:id])
      authorize @config, :update?

      result = Shared::PaymentMethods::Operations::TogglePaymentMethod.new.call(
        key:     @config.key,
        enabled: !@config.enabled?
      )

      case result
      in Dry::Monads::Success(_)
        redirect_to admin_payment_method_configs_path,
                    notice: t("controllers.payment_method_configs.updated")
      in Dry::Monads::Failure(_)
        redirect_to admin_payment_method_configs_path,
                    alert: t("controllers.payment_method_configs.error")
      end
    end
  end
end
