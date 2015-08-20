class Audit < ActiveRecord::Base
  # Validations
  validates :order_id, presence: true, numericality: { only_integer: true }
end
