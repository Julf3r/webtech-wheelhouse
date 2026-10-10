class Repair < ApplicationRecord
  enum :status, {received: "received", diagnosing: "diagnosing",
    awaiting_approval: "awaiting_approval", approved: "approved", rejected: "rejected",
    in_repair: "in_repair", ready_for_pickup: "ready_for_pickup", completed: "completed"}

  enum :customer_decision,
  { approved: "approved", rejected: "rejected" },
  prefix: :customer

  belongs_to :bike
  belongs_to :mechanic, class_name: "Staff", optional: true


  has_many :repair_services, dependent: :destroy
  has_many :services, through: :repair_services, dependent: :restrict_with_error

  accepts_nested_attributes_for :repair_services,
                              allow_destroy: true,
                              reject_if: :all_blank

  scope :by_newest_first, -> { order(received_at: :desc) }

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

  
  has_many_attached :intake_photos do |attachable|
    attachable.variant :thumb, resize_to_fill: [96, 96]
    attachable.variant :display, resize_to_limit: [900, 900]
  end

  has_rich_text :diagnosis

  validate :validate_intake_photos

  private

  def validate_intake_photos
    intake_photos.each do |photo|
      blob = photo.blob

      unless blob.content_type.in?(%w[image/jpeg image/png image/webp])
        errors.add(
          :intake_photos,
          "#{blob.filename} must be a JPEG, PNG or WebP image"
        )
      end

      if blob.byte_size > 5.megabytes
        errors.add(
          :intake_photos,
          "#{blob.filename} must be 5 MB or smaller"
        )
      end
    end
  end
  
  
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
