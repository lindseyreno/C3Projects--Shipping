require 'vcr'

VCR.configure do |c|
   c.hook_into :webmock
   c.cassette_library_dir = 'spec/support/vcr_cassettes'
   # c.configure_rspec_metadata!
   # c.allow_http_connections_when_no_cassette = true if real_requests
   # c.default_cassette_options = {:record => :new_episodes}
end
