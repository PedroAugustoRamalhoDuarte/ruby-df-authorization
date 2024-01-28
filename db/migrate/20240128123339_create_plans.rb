class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :task_list_limit
      t.integer :task_limit

      t.timestamps
    end
  end
end
