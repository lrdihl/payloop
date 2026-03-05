class Plan < ApplicationRecord
  include Discard::Model

  CURRENCIES     = %w[BRL USD].freeze
  INTERVAL_TYPES = %w[month year].freeze

  composed_of :price,
    class_name: "Shared::Values::Money",
    mapping: [%w[price_cents cents], %w[currency currency]],
    constructor: ->(cents, currency) { Shared::Values::Money.new(cents: cents, currency: currency) }

  validates :name,           presence: true
  validates :price_cents,    presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency,       presence: true, inclusion: { in: CURRENCIES }
  validates :interval_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :interval_type,  presence: true, inclusion: { in: INTERVAL_TYPES }
  validates :active,         inclusion: { in: [true, false] }

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
