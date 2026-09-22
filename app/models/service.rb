class Service < ApplicationRecord
  has_many :repair_services, dependent: :restrict_with_error
  has_many :repairs, through: :repair_services

  validates :name, presence: true
  validetes :current_price, presence: true, numericality: {greater_than_or_equal_to: 0}
end