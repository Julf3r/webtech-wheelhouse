class Customer < ApplicationRecord
  validates :name, :phone, presence: true
  
  has_many :bikes, dependent: :restrict_with_error
  has_many :repairs, through: :bikes, dependent: :restrict_with_error

  scope :by_name, -> { order(:name) }
end