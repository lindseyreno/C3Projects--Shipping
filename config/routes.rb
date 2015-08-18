Rails.application.routes.draw do
  get '/get_ups_rates', to: 'api#get_ups_rates', as: 'get_ups_rates'
end
