require 'rails_helper'
require 'support/vcr_setup'

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

      it "returns only #{UpsInterface::DESIRED_SERVICES.count} rates" do
        expect(@rates.count).to eq UpsInterface::DESIRED_SERVICES.count
      end

      it "returns the #{UpsInterface::DESIRED_SERVICES.count} desired rates" do
        service_names = @rates.collect{ |rate| rate["service_name"] }
        expect(service_names).to eq UpsInterface::DESIRED_SERVICES
      end

      it "returns rates in ascending order of price" do
        expect(@rates.first["total_price"]).to be <= @rates.last["total_price"]
      end

      it "includes service name, total price and delivery date" do
        expect(@rates.first.keys).to eq ["service_name", "total_price", "delivery_date"]
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

      it "returns only #{UspsInterface::DESIRED_SERVICES.count} rates" do
        expect(@rates.count).to eq UspsInterface::DESIRED_SERVICES.count
      end

      it "returns the #{UspsInterface::DESIRED_SERVICES.count} desired rates" do
        service_names = @rates.collect{ |rate| rate["service_name"] }
        expect(service_names).to eq UspsInterface::DESIRED_SERVICES
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

      all_rates = UpsInterface::DESIRED_SERVICES + UspsInterface::DESIRED_SERVICES
      it "returns #{all_rates.count} rates" do
        api_call
        expect(@rates.count).to eq all_rates.count
      end
    end
  end

  describe "POST #log_shipping_choice" do
    context "valid shipping choice" do
      let(:valid_shipping_choice) {
        "{\"shipping_choice\":{\"shipping_service\":\"UPS Ground\",\"shipping_cost\":1000,\"order_id\":1}}"
      }
      before :each do
        VCR.use_cassette "controllers/api_controller/valid_log_shipping_choice" do
          post :log_shipping_choice, json_data: valid_shipping_choice
        end
      end

      it "is successful" do
        expect(response.response_code).to eq 201
      end

      it "returns JSON" do
        expect(response.header['Content-Type']).to include 'application/json'
      end

      it "creates an audit log record" do
        expect(Audit.count).to eq 1
      end
    end

    context "invalid shipping choice" do
      let(:invalid_shipping_choice) {
        "{\"shipping_choice\":{\"shipping_service\":\"UPS Ground\",\"shipping_cost\":null,\"order_id\":1}}"
      }
      before :each do
        VCR.use_cassette "controllers/api_controller/invalid_log_shipping_choice" do
          post :log_shipping_choice, json_data: invalid_shipping_choice
        end
      end

      it "is responds with 422 Unprocessable Entity" do
        expect(response.response_code).to eq 422
      end
    end
  end
end

# Use the below code for creating test JSON for specs
# {:shipment=> {:origin=>{:country=>"US", :state=>"WA", :city=>"Seattle", :zip=>98101}, :destination=>{:country=>"US", :state=>"CA", :city=>"San Leandro", :zip=>94578}, :packages=>[{:weight=>100, :dimensions=>[12, 12, 12]}]}}
# {:shipping_choice=>{:shipping_service=>"UPS Ground", :shipping_cost=>1000, :order_id=>1}}
