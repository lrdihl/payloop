class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if user_signed_in?
      current_user.admin? ? redirect_to(admin_users_path) : redirect_to(new_user_session_path)
    else
      redirect_to new_user_session_path
    end
  end
end
