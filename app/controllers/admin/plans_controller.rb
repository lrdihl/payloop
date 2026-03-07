module Admin
  class PlansController < ApplicationController
    include Dry::Monads[:result]

    layout "admin"

    before_action :set_plan, only: %i[show edit update destroy]

    def index
      authorize Plan
      @plans = policy_scope(Plan).order(:name)
    end

    def show
      authorize @plan
    end

    def new
      authorize Plan
      @plan = Plan.new
    end

    def create
      authorize Plan
      @plan = Plan.new(plan_params)

      result = Plans::Operations::CreatePlan.new.call(plan_params)

      handle_result(result) do |plan|
        redirect_to admin_plan_path(plan), notice: t("controllers.plans.created")
      end
    end

    def edit
      authorize @plan
    end

    def update
      authorize @plan

      result = Plans::Operations::UpdatePlan.new.call(plan_params.merge(plan: @plan))

      handle_result(result) do |plan|
        redirect_to admin_plan_path(plan), notice: t("controllers.plans.updated")
      end
    end

    def destroy
      authorize @plan

      result = Plans::Operations::DiscardPlan.new.call(plan: @plan)

      handle_result(result) do
        redirect_to admin_plans_path, notice: t("controllers.plans.destroyed")
      end
    end

    private

    def set_plan
      @plan = Plan.find(params[:id])
    end

    def plan_params
      params.require(:plan)
            .permit(:name, :description, :price_cents, :currency, :interval_count, :interval_type,
                    :duration_count, :duration_type, :renewable, :active)
            .to_h
            .deep_symbolize_keys
    end

    def action_for_failure
      action_name == "create" ? :new : :edit
    end
  end
end
