require 'rails_helper'
require 'support/vcr_setup'

RSpec.describe ApiController, type: :controller do
  let(:shipment) {
    "{\"shipment\":{\"origin\":{\"country\":\"US\",\"state\":\"WA\",\"city\":\"Seattle\",\"zip\":98101},\"destination\":{\"country\":\"US\",\"state\":\"CA\",\"city\":\"San Leandro\",\"zip\":94578},\"packages\":[{\"weight\":100,\"dimensions\":[12,12,12]}]}}"
  }
  let(:invalid_shipment) {
    "{\"shipment\":{\"origin\":{\"country\":\"US\",\"state\":null,\"city\":\"Seattle\",\"zip\":null},\"destination\":{\"country\":\"US\",\"state\":\"CA\",\"city\":\"San Leandro\",\"zip\":94578},\"packages\":[{\"weight\":100,\"dimensions\":[12,12,12]}]}}"
  }
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
        expect(@rates.count).to be <= UpsInterface::DESIRED_SERVICES.count
      end

      it "returns the desired services" do
        service_names = @rates.collect{ |rate| rate["service_name"] }
        service_names.each do |service|
          expect(UpsInterface::DESIRED_SERVICES).to include service
        end
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
        expect(@rates.count).to be <= UspsInterface::DESIRED_SERVICES.count
      end

      it "returns the desired services" do
        service_names = @rates.collect{ |rate| rate["service_name"] }
        service_names.each do |service|
          expect(UspsInterface::DESIRED_SERVICES).to include service
        end
      end

      it "returns rates in ascending order of price" do
        expect(@rates.first["total_price"]).to be <= @rates.last["total_price"]
      end
    end
  end

  describe "GET #get_all_rates" do
    context "valid shipment details" do
      let(:valid_api_call) do
        VCR.use_cassette "controllers/api_controller/get_all_rates_valid" do
          get :get_all_rates, json_data: shipment
          @rates = JSON.parse response.body
        end
      end

      it "is successful" do
        valid_api_call
        expect(response.response_code).to eq 200
      end

      it "returns JSON" do
        valid_api_call
        expect(response.header['Content-Type']).to include 'application/json'
      end

      context "the returned JSON object" do
        it "is an array" do
          valid_api_call
          expect(@rates).to be_an_instance_of Array
        end

        all_rates = UpsInterface::DESIRED_SERVICES + UspsInterface::DESIRED_SERVICES
        it "returns #{all_rates.count} rates" do
          valid_api_call
          expect(@rates.count).to be <= all_rates.count
        end
      end
    end

    context "invalid shipment details" do
      let(:invalid_api_call) do
        get :get_all_rates, json_data: invalid_shipment
        @error_message = JSON.parse response.body
      end
    
      it "responds with 422 Unprocessable Entity" do
        invalid_api_call
        expect(response.response_code).to eq 422
      end
    
      it "returns JSON" do
        invalid_api_call
        expect(response.header['Content-Type']).to include 'application/json'
      end
    
      it "returns an error message" do
        invalid_api_call
        expect(@error_message).to be_an_instance_of Hash
      end
    end
  end

  describe "POST #log_shipping_choice" do
    context "valid shipping choice" do
      let(:valid_shipping_choice) {
        "{\"shipping_choice\":{\"shipping_service\":\"UPS Ground\",\"shipping_cost\":1000,\"order_id\":1}}"
      }
      before :each do
        post :log_shipping_choice, json_data: valid_shipping_choice
        @audit_record = JSON.parse response.body
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

      it "returns a JSON object of the new Audit record" do
        expect(@audit_record).to be_an_instance_of Hash
      end
    end

    context "invalid shipping choice" do
      let(:invalid_shipping_choice) {
        "{\"shipping_choice\":{\"shipping_service\":\"UPS Ground\",\"shipping_cost\":null,\"order_id\":1}}"
      }
      before :each do
        post :log_shipping_choice, json_data: invalid_shipping_choice
        @error_message = JSON.parse response.body
      end

      it "is responds with 422 Unprocessable Entity" do
        expect(response.response_code).to eq 422
      end

      it "does not create an Audit log record" do
        expect(Audit.count).to eq 0
      end

      it "returns an error message" do
        expect(@error_message).to be_an_instance_of Hash
      end
    end
  end
end

# Use the below code for creating test JSON for specs
# valid shipment
# {:shipment=> {:origin=>{:country=>"US", :state=>"WA", :city=>"Seattle", :zip=>98101}, :destination=>{:country=>"US", :state=>"CA", :city=>"San Leandro", :zip=>94578}, :packages=>[{:weight=>100, :dimensions=>[12, 12, 12]}]}}
# invalid shipment
# {:origin=>{:country=>"US", :state=>nil, :city=>"Seattle", :zip=>nil}, :destination=>{:country=>"US", :state=>"CA", :city=>"San Leandro", :zip=>94578}, :packages=>[{:weight=>100, :dimensions=>[12, 12, 12]}]}}
# valid shipping choice
# {:shipping_choice=>{:shipping_service=>"UPS Ground", :shipping_cost=>1000, :order_id=>1}}
