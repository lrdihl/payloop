class Plan < ApplicationRecord
  include Discard::Model

  CURRENCIES     = %w[BRL USD].freeze
  INTERVAL_TYPES = %w[month year].freeze
  DURATION_TYPES = %w[month year].freeze

  composed_of :price,
    class_name:  "Shared::Values::Money",
    mapping:     [ %w[price_cents cents], %w[currency currency] ],
    constructor: ->(cents, currency) { Shared::Values::Money.new(cents: cents, currency: currency) }

  composed_of :interval,
    class_name:  "Shared::Values::Period",
    mapping:     [ %w[interval_count count], %w[interval_type type] ],
    constructor: ->(count, type) { Shared::Values::Period.new(count: count, type: type) }

  composed_of :duration,
    class_name:  "Shared::Values::Period",
    mapping:     [ %w[duration_count count], %w[duration_type type] ],
    constructor: ->(count, type) { Shared::Values::Period.new(count: count, type: type) }

  validates :name,           presence: true
  validates :price_cents,    presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency,       presence: true, inclusion: { in: CURRENCIES }
  validates :interval_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :interval_type,  presence: true, inclusion: { in: INTERVAL_TYPES }
  validates :active,         inclusion: { in: [ true, false ] }

  has_many :subscriptions, dependent: :restrict_with_error

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  validates :duration_type,  inclusion: { in: DURATION_TYPES }, allow_nil: true
  validates :duration_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate  :duration_fields_consistency

  private

  def duration_fields_consistency
    if duration_count.present? && duration_type.blank?
      errors.add(:duration_type, :blank)
    elsif duration_type.present? && duration_count.blank?
      errors.add(:duration_count, :blank)
    end
  end
end
