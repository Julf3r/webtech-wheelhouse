class AddLab11Fields < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string,
      null: false, default: 'counter'

    add_reference :users, :staff,
      null: true,
      index: true,
      foreign_key: { to_table: :staff }
    
    add_reference :repairs, :received_by,
      null: true,
      foreign_key: { to_table: :users }

    add_index :users, "LOWER(email_address)",
      unique: true,
      name: "index_users_on_lower_email"
  end
end
