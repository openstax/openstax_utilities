require "openstax/utilities/engine"
require "openstax/utilities/version"
require "openstax/utilities/exceptions"
require "openstax/utilities/settings"
require "openstax/utilities/access"
require "openstax/utilities/enum"
require "openstax/utilities/ruby"
require "openstax/utilities/text"

require 'openstax/utilities/blocks/block_base'
require 'openstax/utilities/blocks/section_block'
require 'openstax/utilities/blocks/table_block'
require 'openstax/utilities/blocks/table_cell_block'
require 'openstax/utilities/blocks/table_row_block'

module OpenStax
  module Utilities

    # ASSET_FILES = %w(openstax_utilities.css openstax_utilities.js)

    # ActiveSupport.on_load(:before_initialize) do
    #   Rails.configuration.assets.precompile += OpenStax::Utilities::ASSET_FILES
    # end

    class << self

      ###########################################################################
      #
      # Configuration machinery.
      #
      # To configure OpenStax Utilities, put the following code in your applications 
      # initialization logic (eg. in the config/initializers in a Rails app)
      #
      #   OpenStax::Utilities.configure do |config|
      #     config.<parameter name> = <parameter value>
      #     ...
      #   end
      #
      
      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

      class Configuration
        # attr_accessor :some_parameter_name_here
        
        def initialize      
          # @some_parameter_name_here = some value here
          super
        end
      end

    end

  end
end

