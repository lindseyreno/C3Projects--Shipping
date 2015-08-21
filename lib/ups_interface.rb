class UpsInterface
  attr_reader :ups
  DESIRED_SERVICES = ["UPS Ground", "UPS Second Day Air", "UPS Next Day Air"]

  def initialize
    @ups = ActiveShipping::UPS.new(
      login: ENV['ACTIVESHIPPING_UPS_LOGIN'],
      password: ENV['ACTIVESHIPPING_UPS_PASSWORD'],
      key: ENV['ACTIVESHIPPING_UPS_KEY']
      )
  end

  # We would like to refactor this method,
  # and combine it with UspsInterface.process_rates,
  # but we ran out of time.
  def process_rates(shipment)
    packages = ShippingInterface.create_packages(shipment["packages"])
    origin = ShippingInterface.create_location(shipment["origin"])
    destination = ShippingInterface.create_location(shipment["destination"])

    return false unless packages && origin && destination

    begin
      response = ups.find_rates(origin, destination, packages, {pickup_time: Date.current})
      rates = response.rates if response
    rescue
      return false
    end

    ## return only the desired rates
    collected_rates = []
    rates.each do |rate|
      collected_rates << rate if DESIRED_SERVICES.include?(rate.service_name)
    end

    ## pull out just the service_name and calculate the total rate
    rate_info = []
    collected_rates.each do |rate|
      rate_info << {
        service_name: rate.service_name, total_price: rate.total_price, delivery_date: rate.delivery_date
      }
    end
    return rate_info
  end
end

### All the service_names

# ["UPS Ground",
#  "UPS Three-Day Select",
#  "UPS Second Day Air",
#  "UPS Next Day Air Saver",
#  "UPS Next Day Air Early A.M.",
#  "UPS Next Day Air"]
