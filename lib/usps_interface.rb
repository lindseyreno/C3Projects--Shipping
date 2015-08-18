class UspsInterface
  attr_reader :usps

  def initialize
    @usps = ActiveShipping::USPS.new(
      login: ENV['ACTIVESHIPPING_USPS_LOGIN'],
      test: true)
  end
end
