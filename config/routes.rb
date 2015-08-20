Rails.application.routes.draw do
  get '/get_ups_rates', to: 'api#get_ups_rates'
  get '/get_usps_rates', to: 'api#get_usps_rates'
  get '/get_all_rates', to: 'api#get_all_rates'
end
