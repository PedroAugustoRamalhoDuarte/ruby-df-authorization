# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  pre_check :allow_admins
  # Configure additional authorization contexts here
  # (`user` is added by default).
  #
  #   authorize :account, optional: true
  #
  # Read more about authorization context: https://actionpolicy.evilmartians.io/#/authorization_context

  private

  # Define shared methods useful for most policies.
  # For example:
  #
  def owner?
    record.user_id == user.id
  end

  def allow_admins
    allow! if user.admin?
  end
end
