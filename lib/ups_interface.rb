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
