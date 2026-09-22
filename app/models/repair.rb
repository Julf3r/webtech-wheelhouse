class Repair < ApplicationRecord
  enum status: {received: "received", diagnosing: "diagnosing",
    awaiting_approval: "awaiting_approval", approved: "approved", rejected: "rejected",
    in_repair: "in_repair", ready_for_pickup: "ready_for_pickup", completed: "completed"}

  enum customer_decision: {approved: "approved", rejected: "rejected"}

  belongs_to :bike
  belongs_to :mechanic, class_name: "Staff", optional: true


  has_many :repair_services
  has_many :services, through: :repair_services


  scope :pending, -> { where(handed_back_at: nil) }
  scope :overdue, -> { pending.where(:promised_on => ..Date.current) }

  validates :promised_on, presence: true
  validates :quoted_price, presence: true, numericality: {greater_than_or_equal_to: 0}

  def pending?
    handed_back_at.nil?
  end

  def overdue?
    pending? &&promised_on <= Date.current
  end