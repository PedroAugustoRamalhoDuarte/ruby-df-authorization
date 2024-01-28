class User < ApplicationRecord
  belongs_to :plan
  has_many :user_task_lists, dependent: :destroy
  has_many :task_lists, through: :user_task_lists

  enum role: { normal: 0, admin: 1 }
end
