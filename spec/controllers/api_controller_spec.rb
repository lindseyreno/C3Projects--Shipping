require 'rails_helper'
require 'support/vcr_setup'

RSpec.describe ApiController, type: :controller do
  describe "GET #get_ups_rates" do
    let(:shipment) {
      # "{\"shipment\":{\"origin\":{\"country\":\"US\",\"state\":\"WA\",\"city\":\"Seattle\",\"zip\":98101},\"destination\":{\"country\":\"US\",\"state\":\"WA\",\"city\":\"Vancouver\",\"zip\":98660},\"packages\":[{\"weight\":100,\"dimensions\":[12,12,12]}]}}" }
      "{\"shipment\":{\"origin\":{\"country\":\"US\",\"state\":\"WA\",\"city\":\"Seattle\",\"zip\":98101},\"destination\":{\"country\":\"US\",\"state\":\"CA\",\"city\":\"San Leandro\",\"zip\":94578},\"packages\":[{\"weight\":100,\"dimensions\":[12,12,12]}]}}" }   
    before :each do
      VCR.use_cassette "controllers/get_ups_rates" do
        @response = get :get_ups_rates, shipment: shipment
      end
    end

    it "is successful" do
      expect(@response.response_code).to eq 200
    end

    it "returns json" do
      expect(response.header['Content-Type']).to include 'application/json'
    end

    context "the returned JSON object" do
      before :each do
        VCR.use_cassette "controllers/get_ups_rates" do
          get :get_ups_rates, shipment: shipment
          data = JSON.parse response.body
          @rates = data["rates"]
        end
      end

      it "is an array" do
        expect(@rates).to be_an_instance_of Array
      end
    end

  end

end

# {:shipment=> {:origin=>{:country=>"US", :state=>"WA", :city=>"Seattle", :zip=>98101}, :destination=>{:country=>"US", :state=>"CA", :city=>"San Leandro", :zip=>94578}, :packages=>[{:weight=>100, :dimensions=>[12, 12, 12]}]}}
