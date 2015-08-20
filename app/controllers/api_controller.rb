class ApiController < ApplicationController
  def get_ups_rates
    ups = UpsInterface.new
    shipment = JSON.parse(params[:json_data])["shipment"]
    rate_info = ups.process_rates(shipment)

    render json: rate_info
  end

  def get_usps_rates
    usps = UspsInterface.new
    shipment = JSON.parse(params[:json_data])["shipment"]
    rate_price_pairs = usps.process_rates(shipment)

    render json: rate_price_pairs
  end

  def get_all_rates
    shipment = JSON.parse(params[:json_data])["shipment"]
    ups_rates = UpsInterface.new.process_rates(shipment)
    usps_rates = UspsInterface.new.process_rates(shipment)
    all_rates = ups_rates + usps_rates

    render json: all_rates
  end

  def log_shipping_choice
    render json: {}, status: 201
  end
end
