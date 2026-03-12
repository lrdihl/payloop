module Shared
  module Concerns
    module StaleObjectHandler
      STALE_FAILURE = { type: :stale, errors: { base: [ "registro alterado por outro processo" ] } }.freeze

      private

      def guard_stale
        yield
      rescue ActiveRecord::StaleObjectError
        Dry::Monads::Failure(STALE_FAILURE)
      end
    end
  end
end
