module Subscriptions
  module Contracts
    class CreateSubscriptionContract < Dry::Validation::Contract
      params do
        required(:user_id).filled(:integer)
        required(:plan_id).filled(:integer)
        required(:joined_at).filled(:date)
      end
    end
  end
end
