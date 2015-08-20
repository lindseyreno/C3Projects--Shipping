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
  end
end
