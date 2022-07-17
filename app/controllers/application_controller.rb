class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_userstamp

  def new_session_path(scope)
    new_user_session_path
  end

  private

  def set_userstamp
    if current_user
      RequestStore.store[:current_user_email] = current_user.email
    end
  end
end
