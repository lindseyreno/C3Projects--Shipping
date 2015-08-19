class ApiController < ApplicationController
  DESIRED_RATES = ["UPS Ground", "UPS Second Day Air", "UPS Next Day Air"]

  def get_ups_rates
    ups = UpsInterface.new.ups
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

    response = ups.find_rates(origin, destination, packages)
    rates = response.rates

    collected_rates = []
    rates.each do |rate|
      collected_rates << rate if DESIRED_RATES.include?(rate.service_name)
    end

    render json: collected_rates
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

    render json: rates
  end
end
