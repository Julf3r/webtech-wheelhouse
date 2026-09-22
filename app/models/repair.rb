class Repair < ApplicationRecord
  enum :status, {received: "received", diagnosing: "diagnosing",
    awaiting_approval: "awaiting_approval", approved: "approved", rejected: "rejected",
    in_repair: "in_repair", ready_for_pickup: "ready_for_pickup", completed: "completed"}

  enum :customer_decision,
  { approved: "approved", rejected: "rejected" },
  prefix: :customer

  belongs_to :bike
  belongs_to :mechanic, class_name: "Staff", optional: true


  has_many :repair_services
  has_many :services, through: :repair_services


  scope :pending, -> { where(handed_back_at: nil) }
  scope :overdue, -> { pending.where("promised_on < ?", Date.current) }

  validates :received_at, :status, presence: true
  validates :promised_on, presence: true
  validates :quoted_price, numericality: {greater_than: 0}, allow_nil: true

  def pending?
    handed_back_at.nil?
  end

  def overdue?
    pending? && promised_on < Date.current
  end

  validate :dates_make_sense
  validate :customer_decision_matches_lifecycle

  private
  
  def dates_make_sense
    if handed_back_at.present? && handed_back_at.to_date < received_at.to_date
      errors.add(:handed_back_at, "cannot be before the repair was received")
    end

    if promised_on.present? && received_at.present? &&
      promised_on < received_at.to_date
      errors.add(:promised_on, "cannot be before the repair was received")
    end
  end

  def customer_decision_matches_lifecycle
    if (in_repair? || ready_for_pickup? || completed?) &&
      customer_decision.blank?
        errors.add(:customer_decision, "must be recorded after the customer's decision")
    end
  end
end
