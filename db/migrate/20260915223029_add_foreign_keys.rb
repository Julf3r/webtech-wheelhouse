class AddForeignKeys < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :bikes, :customers, column: :customer_id
    add_index :bikes, :customer_id

    add_foreign_key :repairs, :bikes, column: :bike_id
    add_index :repairs, :bike_id

    add_foreign_key :repairs, :staff, column: :mechanic_id
    add_index :repairs, :mechanic_id

    add_foreign_key :repair_services, :repairs, column: :repair_id
    add_index :repair_services, :repair_id

    add_foreign_key :repair_services, :services, column: :service_id
    add_index :repair_services, :service_id
  end
end