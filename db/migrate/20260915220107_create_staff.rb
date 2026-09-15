class CreateStaff < ActiveRecord::Migration[8.1]
  def change
    create_table :staff do |t|
      t.string :name, null: false
      t.string :role, null: false

      t.timestamps
    end
  end
end