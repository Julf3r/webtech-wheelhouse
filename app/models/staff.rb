class Staff < ApplicationRecord
  self.table_name = "staff"

  has_many :repairs, foreign_key: :mechanic_id

  validates :name, presence: true
end