require "openstax/utilities/action_list"

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'OpenStax'
end

module OpenStax
  module Utilities
    class Engine < ::Rails::Engine
      isolate_namespace OpenStax::Utilities

      config.after_initialize do
        OSU::SITE_NAME = ::Rails.application.class.parent_name.underscore
      end

      config.generators do |g|
        g.test_framework :rspec, :fixture => false
        g.assets false
        g.helper false
      end
    end
  end
end