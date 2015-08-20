require 'rails_helper'
require 'support/vcr_setup'
require 'ups_interface'

RSpec.describe ApiController, type: :controller do
  let(:shipment) {
    "{\"shipment\":{\"origin\":{\"country\":\"US\",\"state\":\"WA\",\"city\":\"Seattle\",\"zip\":98101},\"destination\":{\"country\":\"US\",\"state\":\"CA\",\"city\":\"San Leandro\",\"zip\":94578},\"packages\":[{\"weight\":100,\"dimensions\":[12,12,12]}]}}" }

  describe "GET #get_ups_rates" do
    before :each do
      VCR.use_cassette "controllers/get_ups_rates" do
        get :get_ups_rates, json_data: shipment
        @rates = JSON.parse response.body
      end
    end

    it "is successful" do
      expect(response.response_code).to eq 200
    end

    it "returns JSON" do
      expect(response.header['Content-Type']).to include 'application/json'
    end

    context "the returned JSON object" do
      it "is an array" do
        expect(@rates).to be_an_instance_of Array
      end

      it "returns only #{UpsInterface::DESIRED_UPS_RATES.count} rates" do
        expect(@rates.count).to eq UpsInterface::DESIRED_UPS_RATES.count
      end

      it "returns the #{UpsInterface::DESIRED_UPS_RATES.count} desired rates" do
        service_names = @rates.collect{ |rate| rate["service_name"] }
        expect(service_names).to eq UpsInterface::DESIRED_UPS_RATES
      end

      it "returns rates in ascending order of price" do
        expect(@rates.first["total_price"]).to be <= @rates.last["total_price"]
      end
    end
  end

  describe "GET #get_usps_rates" do
    before :each do
      VCR.use_cassette "controllers/get_usps_rates" do
        get :get_usps_rates, json_data: shipment
        @rates = JSON.parse response.body
      end
    end

    it "is successful" do
      expect(response.response_code).to eq 200
    end

    it "returns JSON" do
      expect(response.header['Content-Type']).to include 'application/json'
    end

    context "the returned JSON object" do
      it "is an array" do
        expect(@rates).to be_an_instance_of Array
      end

      it "returns only #{UspsInterface::DESIRED_USPS_RATES.count} rates" do
        expect(@rates.count).to eq UspsInterface::DESIRED_USPS_RATES.count
      end

      it "returns the #{UspsInterface::DESIRED_USPS_RATES.count} desired rates" do
        service_names = @rates.collect{ |rate| rate["service_name"] }
        expect(service_names).to eq UspsInterface::DESIRED_USPS_RATES
      end

      it "returns rates in ascending order of price" do
        expect(@rates.first["total_price"]).to be <= @rates.last["total_price"]
      end
    end
  end

  describe "GET #get_all_rates" do
    let(:api_call) do
      VCR.use_cassette "controllers/get_all_rates" do
        get :get_all_rates, json_data: shipment
        @rates = JSON.parse response.body
      end
    end

    it "is successful" do
      api_call
      expect(response.response_code).to eq 200
    end

    it "returns JSON" do
      api_call
      expect(response.header['Content-Type']).to include 'application/json'
    end

    context "the returned JSON object" do
      it "is an array" do
        api_call
        expect(@rates).to be_an_instance_of Array
      end

      all_rates = UpsInterface::DESIRED_UPS_RATES + UspsInterface::DESIRED_USPS_RATES
      it "returns #{all_rates.count} rates" do
        api_call
        expect(@rates.count).to eq all_rates.count
      end
    end
  end
end

# Use the below code for creating test JSON for specs
# {:shipment=> {:origin=>{:country=>"US", :state=>"WA", :city=>"Seattle", :zip=>98101}, :destination=>{:country=>"US", :state=>"CA", :city=>"San Leandro", :zip=>94578}, :packages=>[{:weight=>100, :dimensions=>[12, 12, 12]}]}}
