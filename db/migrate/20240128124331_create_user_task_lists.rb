class CreateUserTaskLists < ActiveRecord::Migration[7.1]
  def change
    create_table :user_task_lists do |t|
      t.references :task_list, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
