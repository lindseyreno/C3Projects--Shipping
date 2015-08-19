Rails.application.routes.draw do
  get '/get_ups_rates?q=', to: 'api#get_ups_rates', as: 'get_ups_rates'
  get '/get_usps_rates?q=', to: 'api#get_usps_rates', as: 'get_usps_rates'
  get '/get_all_rates?q=', to: 'api#get_all_rates', as: 'get_all_rates'
end
