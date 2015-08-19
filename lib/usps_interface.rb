class UspsInterface
  attr_reader :usps

  def initialize
    @usps = ActiveShipping::USPS.new(
      login: ENV['ACTIVESHIPPING_USPS_LOGIN'],
      test: true)
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
