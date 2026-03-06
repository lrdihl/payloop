module Shared
  module PaymentMethods
    class Registry
      @methods = {}

      def self.register(key, klass)
        @methods[key.to_sym] = klass
      end

      def self.find(key)
        @methods.fetch(key.to_sym)
      end

      def self.all
        @methods.dup
      end
    end
  end
end
