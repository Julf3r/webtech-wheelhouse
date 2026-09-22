class RepairService < ApplicationRecord
  belongs_to :repair
  belongs_to :service

  validates :charged_price, presence: true, numericality: {greater_than_or_equal_to: 0}
end