class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.references :plan, null: false, foreign_key: true
      t.integer :role

      t.timestamps
    end
  end
end
