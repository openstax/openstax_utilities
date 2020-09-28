require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = Rails.env.development?
  c.ignore_localhost = true
  c.ignore_request { |request| Addressable::URI.parse(request.uri).path == '/oauth/token' } \
    if Rails.env.development?
  c.preserve_exact_body_bytes { |http_message| !http_message.body.valid_encoding? }
end

VCR_OPTS = {
  # This should default to :none
  record: ENV.fetch('VCR_OPTS_RECORD', :none).to_sym,
  allow_unused_http_interactions: Rails.env.development?
}
