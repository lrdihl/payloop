class Plan < ApplicationRecord
  include Discard::Model

  CURRENCIES = %w[BRL USD].freeze
  INTERVAL_TYPES = %w[month year].freeze

  validates :name,           presence: true
  validates :price_cents,    presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency,       presence: true, inclusion: { in: CURRENCIES }
  validates :interval_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :interval_type,  presence: true, inclusion: { in: INTERVAL_TYPES }
  validates :active,         inclusion: { in: [true, false] }

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
