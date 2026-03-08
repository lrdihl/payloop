module Admin
  class BaseController < ApplicationController
    before_action :require_admin!

    private

    def require_admin!
      unless current_user.admin?
        flash[:alert] = t("flash.unauthorized")
        redirect_to root_path
      end
    end
  end
end
