require 'rails_helper'

RSpec.describe ApiController, type: :controller do
  describe "GET #get_ups_rates" do
    before :each do
      get :get_ups_rates
    end

    it "is successful" do
      expect(response.response_code).to eq 200
    end

    # it "returns ups rates" do
    #   expect(response.header['Content-Type']).to include 'application/json'
    # end
  end

end
