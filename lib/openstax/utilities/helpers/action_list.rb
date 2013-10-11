# Copyright 2011-2013 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module OpenStax::Utilities::Helpers
  module ActionList

    def action_list(options={})
      raise IllegalArgument if options[:records].nil? || options[:list].nil?
      render(:partial => 'osu/shared/action_list', locals: options)
    end

  end
end
