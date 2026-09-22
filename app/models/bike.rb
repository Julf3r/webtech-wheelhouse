class Bike < ApplicationRecord
  belongs_to :customer
  has_many :repairs

  validates :serial_number, presence: true, uniqueness: true
end