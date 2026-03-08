module Shared
  module PaymentMethods
    class Registry
      @methods = {}
      @status = {}

      def self.register(key, klass)
        key = key.to_sym
        @methods[key] = klass
        @status[key] = true
      end

      def self.find(key)
        @methods.fetch(key.to_sym)
      end

      def self.all
        @methods.dup
      end

      def self.disable(key)
        @status[key.to_sym] = false
      end

      def self.enable(key)
        @status[key.to_sym] = true
      end

      def self.active?(key)
        @status.fetch(key.to_sym, false)
      end

      def self.active_methods
        @methods.select { |key, _| @status[key] }
      end

      def self.selectable_methods
        @methods.select { |key, klass| @status[key] && klass.selectable? }
      end
    end
  end
end
