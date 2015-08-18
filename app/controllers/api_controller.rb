class ApiController < ApplicationController
  ORIGIN = ActiveShipping::Location.new(
    country: 'US',
    state: 'WA',
    city: 'Seattle',
    zip: '98101'
    )

  def get_ups_rates
    ups = UpsInterface.new.ups

    ups.find_rates(ORIGIN, destination, packages)
  end
end
