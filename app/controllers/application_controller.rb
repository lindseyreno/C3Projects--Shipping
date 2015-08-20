require 'active_shipping'

# Our classes for interacting with shippers
require 'ups_interface'
require 'usps_interface'
require 'shipping_interface'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
