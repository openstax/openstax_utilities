module OpenStax
  module Utilities
  end
end

OSU = OpenStax::Utilities

require "openstax/utilities/engine"
require "openstax/utilities/version"
require "openstax/utilities/exceptions"
require "openstax/utilities/active_record_extensions"
require "openstax/utilities/settings"
require "openstax/utilities/access"
require "openstax/utilities/enum"
require "openstax/utilities/ruby"
require "openstax/utilities/text"
require "openstax/utilities/network"
require "openstax/utilities/action_list"
require "openstax/utilities/acts_as_numberable"
require "openstax/utilities/delegate_access_control"
require "openstax/utilities/access_policy"
require "openstax/utilities/controller_extensions"

require "openstax/utilities/classy_helper"
require "openstax/utilities/helpers/misc"
require "openstax/utilities/helpers/blocks"
require "openstax/utilities/helpers/partials"
require "openstax/utilities/helpers/action_list"
require "openstax/utilities/helpers/datetime"

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
      # controller_actions_map
      # Maps controller action names (e.g. 'index', 'show', 'new', 'create',
      # 'edit', 'update', 'destroy') to their respective CRUD equivalents
      # (i.e. :create, :read, :update, :destroy) to be called as AccessPolicy
      # actions. Other custom mappings can be specified as well. If no mapping is
      # specified, then the action name is passed directly to AccessPolicy.
      #
      # For example, the default mapping ensures that the 'show' action will ask
      # AccessPolicy for :read permission, while an unmapped 'search' action
      # would ask it for :search permission.
      #
      # If 
      
      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

      class Configuration
        attr_accessor :standard_date_format
        attr_accessor :standard_datetime_format
        attr_accessor :standard_time_format
        attr_accessor :controller_actions_map
        
        def initialize      
          @standard_date_format = "%b %d, %Y"
          @standard_datetime_format = "%b %d, %Y %l:%M %p %Z"
          @standard_time_format = "%l:%M %p %Z"
          @controller_actions_map = {'index' => :read,
                                     'show' => :read,
                                     'new' => :create,
                                     'edit' => :update}
          super
        end
      end

    end

  end
end

