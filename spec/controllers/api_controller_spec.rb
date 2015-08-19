require 'rails_helper'
require 'support/vcr_setup'

RSpec.describe ApiController, type: :controller do
  describe "GET #get_ups_rates" do
    let(:shipment) {
      "{\"shipment\":{\"origin\":{\"country\":\"US\",\"state\":\"WA\",\"city\":\"Seattle\",\"zip\":98101},\"destination\":{\"country\":\"US\",\"state\":\"CA\",\"city\":\"San Leandro\",\"zip\":94578},\"packages\":[{\"weight\":100,\"dimensions\":[12,12,12]}]}}" }
    before :each do
      VCR.use_cassette "controllers/get_ups_rates" do
        get :get_ups_rates, shipment: shipment
      end
    end

    it "is successful" do
      expect(response.response_code).to eq 200
    end

    it "returns json" do
      expect(response.header['Content-Type']).to include 'application/json'
    end

    context "the returned JSON object" do
      before :each do
        VCR.use_cassette "controllers/get_ups_rates" do
          get :get_ups_rates, shipment: shipment
          @rates = JSON.parse response.body
        end
      end

      it "is an array" do
        expect(@rates).to be_an_instance_of Array
      end

      it "returns only #{ApiController::DESIRED_UPS_RATES.count} rates" do
        expect(@rates.count).to eq ApiController::DESIRED_UPS_RATES.count
      end

      it "returns the #{ApiController::DESIRED_UPS_RATES.count} desired rates" do
        service_names = @rates.collect{ |rate| rate["service_name"] }       
        expect(service_names).to eq ApiController::DESIRED_UPS_RATES
      end

      it "returns rates in ascending order of price" do
        expect(@rates.first["total_price"]).to be <= @rates.last["total_price"]
      end
    end
  end

  describe "GET #get_usps_rates" do
    let(:shipment) {
      "{\"shipment\":{\"origin\":{\"country\":\"US\",\"state\":\"WA\",\"city\":\"Seattle\",\"zip\":98101},\"destination\":{\"country\":\"US\",\"state\":\"CA\",\"city\":\"San Leandro\",\"zip\":94578},\"packages\":[{\"weight\":100,\"dimensions\":[12,12,12]}]}}" }
    before :each do
      VCR.use_cassette "controllers/get_usps_rates" do
        get :get_usps_rates, shipment: shipment
      end
    end

    it "is successful" do
      expect(response.response_code).to eq 200
    end

    it "returns json" do
      expect(response.header['Content-Type']).to include 'application/json'
    end

    context "the returned JSON object" do
      before :each do
        VCR.use_cassette "controllers/get_usps_rates" do
          get :get_usps_rates, shipment: shipment
          @rates = JSON.parse response.body
        end
      end
    
      it "is an array" do
        expect(@rates).to be_an_instance_of Array
      end

      it "returns only #{ApiController::DESIRED_USPS_RATES.count} rates" do
        expect(@rates.count).to eq ApiController::DESIRED_USPS_RATES.count
      end

      it "returns the #{ApiController::DESIRED_USPS_RATES.count} desired rates" do
        service_names = @rates.collect{ |rate| rate["service_name"] }       
        expect(service_names).to eq ApiController::DESIRED_USPS_RATES
      end

      it "returns rates in ascending order of price" do
        expect(@rates.first["total_price"]).to be <= @rates.last["total_price"]
      end
    end
  end
end

# Use the below code for creating test JSON for specs
# {:shipment=> {:origin=>{:country=>"US", :state=>"WA", :city=>"Seattle", :zip=>98101}, :destination=>{:country=>"US", :state=>"CA", :city=>"San Leandro", :zip=>94578}, :packages=>[{:weight=>100, :dimensions=>[12, 12, 12]}]}}
