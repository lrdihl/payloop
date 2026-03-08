module Shared
  module PaymentMethods
    class Base
      def self.selectable?
        true
      end

      def human_name
        key = self.class.name.demodulize.underscore
        I18n.t("shared.payment_methods.#{key}")
      end

      def process(payment:)
        raise NotImplementedError, "#{self.class}#process não implementado"
      end
    end
  end
end
