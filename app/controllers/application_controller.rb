class ApplicationController < ActionController::Base
  verify_authorized

  def current_user
    User.normal.first
  end
end
