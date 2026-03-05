module Shared
  module Values
    class Money
      include Comparable

      attr_reader :cents, :currency

      def initialize(cents:, currency: "BRL")
        @cents    = Integer(cents)
        @currency = currency.to_s.upcase
      end

      def <=>(other)
        cents <=> other.cents
      end

      def ==(other)
        other.is_a?(self.class) && cents == other.cents && currency == other.currency
      end

      def to_s
        ActionController::Base.helpers.number_to_currency(
          cents / 100.0,
          unit: currency_symbol,
          separator: ",",
          delimiter: "."
        )
      end

      private

      def currency_symbol
        case currency
        when "BRL" then "R$"
        when "USD" then "$"
        else currency
        end
      end
    end
  end
end
