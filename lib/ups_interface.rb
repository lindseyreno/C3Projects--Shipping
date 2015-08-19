class UpsInterface
  attr_reader :ups
  
  def initialize
    @ups = ActiveShipping::UPS.new(
      login: ENV['ACTIVESHIPPING_UPS_LOGIN'],
      password: ENV['ACTIVESHIPPING_UPS_PASSWORD'],
      key: ENV['ACTIVESHIPPING_UPS_KEY']
      )
  end
end

### All the service_names

# ["UPS Ground",
#  "UPS Three-Day Select",
#  "UPS Second Day Air",
#  "UPS Next Day Air Saver",
#  "UPS Next Day Air Early A.M.",
#  "UPS Next Day Air"]
