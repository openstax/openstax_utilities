module OpenStax::Utilities::Helpers
  module OsuHelper

    def osu
      @@osu_class ||= Class.new(OSU::ClassyHelper) do
        include OpenStax::Utilities::Helpers::Misc
        include OpenStax::Utilities::Helpers::Partials
        include OpenStax::Utilities::Helpers::ActionList
        include OpenStax::Utilities::Helpers::Datetime
      end

      @@osu_class.new(self)
    end

  end
end

ActionController::Base.send :helper, OSU::Helpers::OsuHelper