module OpenStax
  module Utilities
    class Engine < ::Rails::Engine
      # isolate_namespace OpenStax::Utilities

      initializer "openstax_utilities.assets.precompile" do |app|
        app.config.assets.precompile += %w(openstax_utilities.css openstax_utilities.js)
      end
    end
  end
end

OSU = OpenStax::Utilities
