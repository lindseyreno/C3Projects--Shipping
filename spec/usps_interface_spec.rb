require 'rails_helper'
require 'usps_interface'
require 'shipping_interface'
require 'support/vcr_setup'

RSpec.describe UspsInterface do
  describe "#process_rates" do
    context "valid shipment" do
      let(:valid_shipment) do
        {"origin"=>{"country"=>"US", "state"=>"WA", "city"=>"Seattle", "zip"=>98101}, "destination"=>{"country"=>"US", "state"=>"CA", "city"=>"San Leandro", "zip"=>94578}, "packages"=>[{"weight"=>100, "dimensions"=>[12, 12, 12]}]}
      end

      before :each do
        VCR.use_cassette "lib/usps_interface/process_rates_valid" do
          @rates = UspsInterface.new.process_rates(valid_shipment)
        end
      end

      it "returns something" do
        expect(@rates).to_not be_nil
      end

      it "returns an array" do
        expect(@rates).to be_an_instance_of Array
      end

      it "returned rates include service_name key" do
        first_rate = @rates.first
        expect(first_rate.keys).to include :service_name
      end

      it "returned rates include total_price" do
        first_rate = @rates.first
        expect(first_rate.keys).to include :total_price
      end
    end

    context "invalid shipment - no zip" do
      let(:invalid_shipment) do # nil zip
        {"origin"=>{"country"=>"US", "state"=>"WA", "city"=>"Seattle", "zip"=>nil}, "destination"=>{"country"=>"US", "state"=>"CA", "city"=>"San Leandro", "zip"=>94578}, "packages"=>[{"weight"=>100, "dimensions"=>[12, 12, 12]}]}
      end

      before :each do
        @rates = UspsInterface.new.process_rates(invalid_shipment)
      end

      it "returns false" do
        expect(@rates).to eq false
      end
    end

    context "invalid shipment - bad zip" do
      let(:invalid_shipment) do
        {"origin"=>{"country"=>"US", "state"=>"OR", "city"=>"Portland", "zip"=>97082}, "destination"=>{"country"=>"US", "state"=>"CA", "city"=>"San Leandro", "zip"=>94578}, "packages"=>[{"weight"=>100, "dimensions"=>[12, 12, 12]}]}
      end

      before :each do
        VCR.use_cassette "lib/usps_interface/invalid_shipment_mismatch" do
          @rates = UspsInterface.new.process_rates(invalid_shipment)
        end
      end

      it "returns false" do
        expect(@rates).to eq false
      end
    end
  end
end