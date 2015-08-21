require 'rails_helper'
require 'shipping_interface'

RSpec.describe ShippingInterface do
  describe "#self.create_packages" do
    context "valid raw_packages" do
      let(:valid_raw_packages) {
        [{"weight"=>100, "dimensions"=>[12, 12, 12]}, {"weight"=>50, "dimensions"=>[10,10,10]}]
      }
      before :each do
        @packages = ShippingInterface.create_packages(valid_raw_packages)
      end

      it "returns an array" do
        expect(@packages).to be_an_instance_of Array
      end

      it "returns the correct number of objects" do
        expect(@packages.length).to eq valid_raw_packages.length
      end
    end

    context "invalid raw_packages" do
      let(:invalid_raw_packages1) {
        [{"weight"=>100, "dimensions"=>[12, 12, 12]}, {"weight"=>nil, "dimensions"=>[10,10,10]}]
      }
      let(:invalid_raw_packages2) {
        [{"weight"=>100, "dimensions"=>[12, 12, 12]}, {"weight"=>50, "dimensions"=>[10,10]}]
      }

      context "weight is nil" do
        it "returns false" do
          packages = ShippingInterface.create_packages(invalid_raw_packages1)
          expect(packages).to eq false
        end
      end

      context "dimensions is missing a dimension" do
        it "returns false " do
          packages = ShippingInterface.create_packages(invalid_raw_packages2)
          expect(packages).to eq false
        end
      end
    end
  end

  describe "#self.create_location(location)" do
    context "valid location" do
      let(:valid_location) {
        {:country=>"US", :state=>"WA", :city=>"Seattle", :zip=>98101}
      }

      it "returns an ActiveShipping object" do
        location = ShippingInterface.create_location(valid_location)
        expect(location).to be_an_instance_of ActiveShipping::Location
      end
    end

    context "invalid location" do
      let(:invalid_location) {
        {:country=>"US", :state=>nil, :city=>"Seattle", :zip=>98101}
      }

      it "returns false" do
        location = ShippingInterface.create_location(invalid_location)
        expect(location).to eq false
      end
    end
  end
end
