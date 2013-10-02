ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'OpenStax'
end

module OpenStax
  module Utilities
    class Engine < ::Rails::Engine
      isolate_namespace OpenStax::Utilities

      initializer "openstax_utilities.assets.precompile" do |app|
        app.config.assets.precompile += %w(openstax_utilities.css openstax_utilities.js)
      end

      initializer 'openstax_utilities.action_controller' do |app|
        ActiveSupport.on_load :action_controller do
          helper OSU::OsuHelper
        end
      end
    end
  end
end