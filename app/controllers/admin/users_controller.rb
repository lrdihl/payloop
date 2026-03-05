# app/controllers/admin/users_controller.rb
#
# CRUD de usuários para admins.
# O controller é intencionalmente thin: autoriza via Pundit, delega ao domain operation,
# responde ao Result. Nenhuma regra de negócio mora aqui.
#
module Admin
  class UsersController < ApplicationController
    include Dry::Monads[:result]

    layout "admin"

    before_action :set_user, only: %i[show edit update destroy update_role]

    def index
      @users = policy_scope(User).includes(:profile).order(:email)
    end

    def show
      authorize @user
    end

    def new
      authorize User
      @user = User.new
      @user.build_profile
    end

    def create
      authorize User

      result = Identity::Operations::RegisterUser.new.call(
        user_params.merge(password_confirmation: user_params[:password]).merge(profile_params)
      )

      handle_result(result) do |profile|
        redirect_to admin_user_path(profile.user), notice: "Usuário criado com sucesso."
      end
    end

    def edit
      authorize @user
    end

    def update
      authorize @user

      result = Identity::Operations::UpdateProfile.new.call(
        profile:    @user.profile,
        attributes: profile_params
      )

      handle_result(result) do
        redirect_to admin_user_path(@user), notice: "Usuário atualizado."
      end
    end

    def destroy
      authorize @user
      @user.destroy!
      redirect_to admin_users_path, notice: "Usuário removido."
    end

    # PATCH /admin/users/:id/role
    def update_role
      authorize @user, :update_role?

      result = Identity::Operations::UpdateUserRole.new.call(
        user: @user,
        role: params.require(:role)
      )

      handle_result(result) do
        redirect_to admin_user_path(@user), notice: "Papel atualizado."
      end
    end

    private

    def set_user
      @user = User.includes(:profile).find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :role).to_h.deep_symbolize_keys
    end

    def profile_params
      params.require(:user)
            .require(:profile_attributes)
            .permit(:full_name, :document, :phone)
            .to_h
            .deep_symbolize_keys
    end

    def action_for_failure
      action_name == "create" ? :new : :edit
    end
  end
end
