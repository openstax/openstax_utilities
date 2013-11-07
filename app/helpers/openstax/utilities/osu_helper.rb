module OpenStax::Utilities
  module OsuHelper

    def osu
      @@osu_class ||= Class.new(ClassyHelper) do
        include OpenStax::Utilities::Helpers::Blocks
        include OpenStax::Utilities::Helpers::Partials
        include OpenStax::Utilities::Helpers::ActionList
        include OpenStax::Utilities::Helpers::Datetime
      end

      @@osu_class.new(self)
    end

  end
end