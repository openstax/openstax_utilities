# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module OpenStax
  module Utilities

    module DelegateAccessControl

      # Adds code to an ActiveRecord object to delegate its access control methods to
      # another object.
      # @example Model is ordered globally using a 'number' field
      #   class MyModel < ActiveRecord::Base
      #     belongs_to :another
      #     delegate_access_control to: :another
      # @param :to The relationship to which the access control methods should
      #   be delegated.
      # @param :include_sort If true, a "can_be_sorted_by?" method will be included
      #   (Default: false)
      #
      def delegate_access_control(options={})
        configuration = {include_sort: false}
        configuration.update(options) if options.is_a?(Hash)

        raise IllegalArgument, "A :to option must be provided" if configuration[:to].blank?
        
        configuration[:to] = configuration[:to].to_s

        class_eval <<-EOV
          delegate :can_be_read_by?, 
                   :can_be_updated_by?, 
                   to: :#{configuration[:to]}

          # Delegating creation and destroying of this contained object means you can
          # update the containing object
          
          alias_method :can_be_created_by?, :can_be_updated_by?
          alias_method :can_be_destroyed_by?, :can_be_updated_by?

          if #{configuration[:include_sort]}
            alias_method :can_be_sorted_by?, :can_be_updated_by?            
          end
        EOV

      end
       
    end

  end
end
 
ActiveRecord::Base.extend OpenStax::Utilities::DelegateAccessControl