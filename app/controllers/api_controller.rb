class ApiController < ApplicationController
  DESIRED_USPS_RATES = ["USPS First-Class Mail Parcel", "USPS Priority Mail 1-Day"]

  def get_ups_rates
    shipment = JSON.parse(params[:shipment])["shipment"]
    ups = UpsInterface.new
    rate_price_pairs = ups.process_rates(shipment)

    render json: rate_price_pairs
  end

  def get_usps_rates
    usps = UspsInterface.new.usps
    shipment = JSON.parse(params[:shipment])["shipment"]
    raw_packages = shipment["packages"]

    packages = []
    raw_packages.each do |package|
      new_package = ActiveShipping::Package.new(
        package["weight"], package["dimensions"])
      packages << new_package
    end

    origin = ActiveShipping::Location.new(
      country: shipment["origin"]["country"],
      state: shipment["origin"]["state"],
      city: shipment["origin"]["city"],
      zip: shipment["origin"]["zip"]
      )

    destination = ActiveShipping::Location.new(
      country: shipment["origin"]["country"],
      state: shipment["origin"]["state"],
      city: shipment["origin"]["city"],
      zip: shipment["origin"]["zip"]
      )

    response = usps.find_rates(origin, destination, packages)
    rates = response.rates

    ## collect only the desired service rates
    collected_rates = []
    rates.each do |rate|
      collected_rates << rate if DESIRED_USPS_RATES.include?(rate.service_name)
    end

    ## pull out just the service_name and calculate the total rate
    rate_price_pairs = []
    collected_rates.each do |rate|
      collected_prices = 0
      rate.package_rates.each do |package_rate|
        collected_prices += package_rate[:rate]
      end
      rate_price_pairs << {
        service_name: rate.service_name, total_price: collected_prices
      }
    end

    render json: rate_price_pairs
  end

  def get_all_rates
    shipment = JSON.parse(params[:shipment])["shipment"]
    ups_rates = UpsInterface.new.process_rates(shipment)
    # usps_rates = get_usps_rates
    # all_rates = ups_rates + usps_rates

    render json: ups_rates
  end
end
