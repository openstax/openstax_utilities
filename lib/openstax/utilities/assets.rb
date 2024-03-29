require 'request_store'
require_relative 'assets/manifest'

module OpenStax::Utilities
  module Assets
    def self.url
      url = OpenStax::Utilities.configuration.assets_url
      url.ends_with?('/') ? url : "#{url}/"
    end

    def self.url_for(asset)
      "#{url}#{asset}"
    end

    def self.manifest
      RequestStore.store[:assets_manifest] ||= OpenStax::Utilities::Assets::Manifest.new
    end

    def self.tags_for(asset)
      manifest[asset].map do |chunk|
        "<script type='text/javascript' src='#{chunk}' crossorigin='anonymous' async></script>"
      end.join("\n").html_safe
    end

    def self.digest_for(asset)
      Digest::MD5.hexdigest tags_for(asset)
    end
  end
end
