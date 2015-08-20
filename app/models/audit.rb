class Audit < ActiveRecord::Base
  # Validations
  validates :order_id, presence: true, numericality: { only_integer: true }
  validates :shipping_service, presence: true
  validates :shipping_cost, presence: true, numericality: { only_integer: true }
end
