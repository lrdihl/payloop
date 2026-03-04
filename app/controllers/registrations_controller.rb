# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  include Dry::Monads[:result]

  skip_before_action :authenticate_user!, only: %i[new create]

  def new
    self.resource = User.new
  end

  def create
    result = Identity::Operations::RegisterUser.new.call(registration_params)

    handle_result(result) do |profile|
      sign_in(profile.user)
      redirect_to consumer_dashboard_path, notice: "Bem-vindo ao PAYLOOP, #{profile.full_name}!"
    end
  end

  private

  def registration_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      profile_attributes: %i[full_name document phone]
    ).to_h.deep_symbolize_keys.then do |p|
      attrs = p.delete(:profile_attributes) || {}
      p.merge(attrs)
    end
  end

  def action_for_failure
    :new
  end

  def render_failure(status)
    self.resource = User.new
    respond_to do |format|
      format.html { render action_for_failure, status: }
      format.json { render json: { errors: @errors }, status: }
    end
  end
end
