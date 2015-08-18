class ApiController < ApplicationController
  def get_ups_rates
    ups = UpsInterface.new.ups
    shipment = JSON.parse(params[:shipment])
    raw_packages = shipment["packages"]

    binding.pry
    packages = []
    raw_packages.each do |package|
      new_package = ActiveShipping::Package.new(
        package["weight"], package["dimensions"])
      packages << new_package
    end

    origin = ActiveShipping::Location.new(shipment["origin"])

    destination = ActiveShipping::Location.new(shipment["destination"])

    response = ups.find_rates(origin, destination, packages)

    render json: response
  end
end
