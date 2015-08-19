class UpsInterface
  attr_reader :ups
  DESIRED_UPS_RATES = ["UPS Ground", "UPS Second Day Air", "UPS Next Day Air"]

  def initialize
    @ups = ActiveShipping::UPS.new(
      login: ENV['ACTIVESHIPPING_UPS_LOGIN'],
      password: ENV['ACTIVESHIPPING_UPS_PASSWORD'],
      key: ENV['ACTIVESHIPPING_UPS_KEY']
      )
  end

  def process_rates(shipment)
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

    ## return only the desired rates
    collected_rates = []
    rates.each do |rate|
      collected_rates << rate if DESIRED_UPS_RATES.include?(rate.service_name)
    end

    ## pull out just the service_name and calculate the total rate
    rate_price_pairs = []
    collected_rates.each do |rate|
      rate_price_pairs << {
        service_name: rate.service_name, total_price: rate.total_price
      }
    end
    return rate_price_pairs
  end
end

### All the service_names

# ["UPS Ground",
#  "UPS Three-Day Select",
#  "UPS Second Day Air",
#  "UPS Next Day Air Saver",
#  "UPS Next Day Air Early A.M.",
#  "UPS Next Day Air"]
