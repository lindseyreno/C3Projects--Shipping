class ApiController < ApplicationController
  BAD_PARAM_ERROR_MESSAGE = { error_details:
    %Q{The shipping choice is missing a parameter
    or a parameter is in the wrong format.} }

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

    all_rates = ups_rates + usps_rates if ups_rates && usps_rates

    if all_rates
      render json: all_rates, status: 200
    else
      render json: BAD_PARAM_ERROR_MESSAGE, status: 422
    end
  end

  def log_shipping_choice
    shipping_choice = JSON.parse(params[:json_data])["shipping_choice"]
    audit = Audit.new(shipping_choice)
    if audit.save
      render json: Audit.find(audit.id), status: 201
    elsif audit.errors
      render json: BAD_PARAM_ERROR_MESSAGE, status: 422
    end
  end
end
