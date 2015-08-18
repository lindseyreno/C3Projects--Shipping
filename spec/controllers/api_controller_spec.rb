require 'rails_helper'

RSpec.describe ApiController, type: :controller do
  describe "GET #get_ups_rates" do
    let(:shipment) {
      "{\"shipment\":{\"origin\":{\"country\":\"US\",\"state\":\"WA\",\"city\":\"Seattle\",\"zip\":98101},\"destination\":{\"country\":\"US\",\"state\":\"WA\",\"city\":\"Vancouver\",\"zip\":98660},\"packages\":[{\"weight\":100,\"dimensions\":[12,12,12]}]}}" }
    before :each do
      get :get_ups_rates, shipment: shipment
    end

    it "is successful" do
      expect(response.response_code).to eq 200
    end

    # it "returns ups rates" do
    #   expect(response.header['Content-Type']).to include 'application/json'
    # end
  end

end

# {:shipment=>
#   {:origin=>{:country=>"US", :state=>"WA", :city=>"Seattle", :zip=>98101},
#    :destination=>{:country=>"US", :state=>"WA", :city=>"Vancouver", :zip=>98660},
#    :packages=>[{:weight=>100, :dimensions=>[12, 12, 12]}]}}
