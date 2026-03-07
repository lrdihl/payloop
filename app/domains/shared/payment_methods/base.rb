module Shared
  module PaymentMethods
    class Base
      def human_name
        raise NotImplementedError, "#{self.class}#human_name não implementado"
      end

      def process(payment:)
        raise NotImplementedError, "#{self.class}#process não implementado"
      end
    end
  end
end
