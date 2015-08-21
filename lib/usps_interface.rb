class UspsInterface
  attr_reader :usps
  DESIRED_SERVICES = ["USPS First-Class Mail Parcel", "USPS Priority Mail 1-Day"]

  def initialize
    @usps = ActiveShipping::USPS.new(
      login: ENV['ACTIVESHIPPING_USPS_LOGIN'],
      test: true)
  end

  def process_rates(shipment)
    packages = ShippingInterface.create_packages(shipment["packages"])
    origin = ShippingInterface.create_location(shipment["origin"])
    destination = ShippingInterface.create_location(shipment["destination"])

     return false unless packages && origin && destination

    begin
      response = usps.find_rates(origin, destination, packages, {pickup_time: Date.current})
      rates = response.rates if response
    rescue
      return false
    end

    ## collect only the desired service rates
    collected_rates = []
    rates.each do |rate|
      collected_rates << rate if DESIRED_SERVICES.include?(rate.service_name)
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
    return rate_price_pairs
  end
end

#### All the service_names

# ["USPS First-Class Mail Stamped Letter",
#  "USPS First-Class Mail Metered Letter",
#  "USPS Library Mail Parcel",
#  "USPS Media Mail Parcel",
#  "USPS First-Class Mail Parcel",
#  "USPS Priority Mail 1-Day",
#  "USPS Priority Mail 1-Day Medium Flat Rate Box",
#  "USPS Priority Mail Express 1-Day",
#  "USPS Priority Mail Express 1-Day Hold For Pickup",
#  "USPS Priority Mail 1-Day Large Flat Rate Box",
#  "USPS Priority Mail Express 1-Day Flat Rate Boxes Hold For Pickup",
#  "USPS Priority Mail Express 1-Day Flat Rate Boxes"]
