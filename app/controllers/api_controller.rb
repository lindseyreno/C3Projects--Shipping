class ApiController < ApplicationController
  def get_ups_rates
    ups = UpsInterface.new
    shipment = JSON.parse(params[:q])["shipment"]
    rate_price_pairs = ups.process_rates(shipment)

    render json: rate_price_pairs
  end

  def get_usps_rates
    usps = UspsInterface.new
    shipment = JSON.parse(params[:q])["shipment"]
    rate_price_pairs = usps.process_rates(shipment)

    render json: rate_price_pairs
  end

  def get_all_rates
    shipment = JSON.parse(params[:q])["shipment"]
    ups_rates = UpsInterface.new.process_rates(shipment)
    usps_rates = UspsInterface.new.process_rates(shipment)
    all_rates = ups_rates + usps_rates

    render json: all_rates
  end
end
