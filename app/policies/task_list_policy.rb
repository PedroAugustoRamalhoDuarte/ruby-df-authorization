class TaskListPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if user.admin?

    relation.left_outer_joins(:user_task_lists)
            .where(user_id: user.id)
            .or(relation.left_outer_joins(:user_task_lists).where(user_task_lists: { user_id: user.id }))

  end

  def index?
    true
  end

  def show?
    owner? || record.users.include?(user)
  end

  def manage?
    owner?
  end

  def create?
    user.task_lists.count < user.plan.task_list_limit
  end
end