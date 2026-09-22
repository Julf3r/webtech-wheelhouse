class Customer < ApplicationRecord
  validates :name, presence: true
  
  has_many :bikes, dependent: :restrict_with_error
  has_many :repairs, through: :bikes
end