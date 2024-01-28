class UserTaskList < ApplicationRecord
  belongs_to :task_list
  belongs_to :user
end
