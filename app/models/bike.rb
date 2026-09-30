class Bike < ApplicationRecord
  belongs_to :customer
  has_many :repairs, dependent: :restrict_with_error

  validates :make, :model, :color, :serial_number, presence: true
  validates :serial_number, uniqueness: true

  before_validation :normalize_serial_number

  scope :by_make_and_model, -> { order(:make, :model) }

  private

  def normalize_serial_number
    self.serial_number = serial_number&.strip&.upcase
  end

end