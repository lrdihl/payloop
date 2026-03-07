module Shared
  module Values
    class Period
      attr_reader :count, :type

      def initialize(count:, type:)
        @count = count
        @type  = type
      end

      def lifetime?
        count.nil? && type.nil?
      end

      def to_s
        return "—" if lifetime?

        label = I18n.t("shared.interval_types.#{type}", count: count)
        "#{count}x #{label}"
      end

      def advance_from(date)
        return nil if lifetime?

        case type
        when "month" then date >> count
        when "year"  then date >> (count * 12)
        end
      end
    end
  end
end
