require "openstax/utilities/classy_helper"
require "openstax/utilities/helpers/misc"
require "openstax/utilities/helpers/partials"
require "openstax/utilities/helpers/action_list"
require "openstax/utilities/helpers/datetime"

module OpenStax::Utilities
  module OsuHelper

    def osu
      @@osu_class ||= Class.new(ClassyHelper) do
        include OpenStax::Utilities::Helpers::Misc
        include OpenStax::Utilities::Helpers::Partials
        include OpenStax::Utilities::Helpers::ActionList
        include OpenStax::Utilities::Helpers::Datetime
      end

      @@osu_class.new(self)
    end

  end
end

ActiveSupport.on_load(:action_controller_base) do
  ActionController::Base.send :helper, OpenStax::Utilities::OsuHelper
end
