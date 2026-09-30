class Staff < ApplicationRecord
  self.table_name = "staff"

  has_many :repairs, foreign_key: :mechanic_id, dependent: :restrict_with_error

  validates :name, :role, presence: true

  scope :by_name, -> { order(:name) }
end