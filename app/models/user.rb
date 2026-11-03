class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :staff, optional: true
  has_many :received_repairs,
            class_name: "Repair", 
            foreign_key: "received_by_id",
            inverse_of: :received_by

  enum :role, { mechanic: "mechanic", counter: "counter", owner: "owner" }, default: "counter"
  validates :role, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            }
  
  validates :password,
            presence: true,
            length: {
              minimum: 10,
              message: "must be at least 10 characters long"
            },
            if: -> {password.present?}
end
