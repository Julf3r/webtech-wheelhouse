class CreateRepairs < ActiveRecord::Migration[8.1]
  def change
    create_table :repairs do |t|
      t.bigint :bike_id, null: false
      t.bigint :mechanic_id

      t.string :status, null: false, default: "received"

      t.date :promised_on, null: false
      t.datetime :received_at, null: false
      t.datetime :handed_back_at

      t.decimal :quoted_price, precision: 10, scale: 2
      t.string :customer_decision
      t.text :intake_condition

      t.timestamps
    end
  end
end