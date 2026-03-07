module Customer
  class ProfilesController < ApplicationController
    layout "admin"

    before_action :require_customer!

    def show
      @user = current_user
    end

    def edit
      @user = current_user
    end

    def update
      @user = current_user

      result = Identity::Operations::UpdateProfile.new.call(
        profile:    @user.profile,
        attributes: profile_params
      )

      handle_result(result) do
        redirect_to customer_profile_path, notice: "Perfil atualizado com sucesso."
      end
    end

    private

    def require_customer!
      unless current_user.customer?
        flash[:alert] = "Você não tem permissão para realizar esta ação."
        redirect_to root_path
      end
    end

    def profile_params
      params.require(:profile).permit(:full_name, :document, :phone).to_h.deep_symbolize_keys
    end

    def action_for_failure
      :edit
    end
  end
end
