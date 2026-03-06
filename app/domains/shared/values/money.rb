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
          **format_options
        )
      end

      private

      def format_options
        case currency
        when "BRL"
          { unit: "R$", separator: ",", delimiter: ".", format: "%u %n" }
        when "USD"
          { unit: "$", separator: ".", delimiter: ",", format: "%u %n" }
        else
          { unit: currency, separator: ".", delimiter: ",", format: "%u %n" }
        end
      end
    end
  end
end
