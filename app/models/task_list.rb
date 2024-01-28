class TaskList < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy
  has_many :user_task_lists, dependent: :destroy
  has_many :users, through: :user_task_lists
end
