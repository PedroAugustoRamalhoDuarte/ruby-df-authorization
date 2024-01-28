class TaskPolicy < ApplicationPolicy
  def manage?
    allowed_to?(:show?, record.task_list)
  end

  def create?
    record.task.count < record.task_list.user.plan.task_limit
  end
end