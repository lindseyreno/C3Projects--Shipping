require 'rails_helper'

RSpec.describe Audit, type: :model do
  describe "model validations" do
    let(:audit) { build :audit }
    context "order_id" do
      it "requires an order_id" do
        audit.order_id = nil
        audit.valid?
        expect(audit.errors.keys).to include(:order_id)
      end

      it "must be a number" do
        audit.order_id = "a"
        audit.valid?
        expect(audit.errors.keys).to include(:order_id)
      end

      it "must be an integer" do
        audit.order_id = 3.2
        audit.valid?
        expect(audit.errors.keys).to include(:order_id)
      end
    end

    context "shipping_service" do
      it "requires a shipping_service" do
        audit.shipping_service = nil
        audit.valid?
        expect(audit.errors.keys).to include(:shipping_service)
      end
    end

    context "shipping cost" do
      it "requires a shipping_cost" do
        audit.shipping_cost = nil
        audit.valid?
        expect(audit.errors.keys).to include(:shipping_cost)
      end

      it "must be a number" do
        audit.shipping_cost = "a"
        audit.valid?
        expect(audit.errors.keys).to include(:shipping_cost)
      end

      it "must be an integer" do
        audit.shipping_cost = 23.12
        audit.valid?
        expect(audit.errors.keys).to include(:shipping_cost)
      end
    end
  end
end
