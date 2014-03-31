module OpenStax
  module Utilities
    module ControllerExtensions
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Tries to find model if id is given, or returns a new model if not
      def get_model(id_param = nil, klass = nil)
        id_param ||= :id
        id = params[id_param]
        klass ||= controller_name.classify.constantize
        id.nil? ? klass.new : klass.find(id)
      end
    
      module ClassMethods
        # Calls AccessPolicy.require_action_allowed! on all restful actions
        # For create and update, the new params are not yet set
        def require_restful_actions_allowed!(options = {})
          class_eval do
            before_filter({:only => [:show, :new, :create, :edit, :update,
                          :destroy]}.merge(options.except(:id_param,
                                                          :model_class))) do |c|

              case c.action_name
              when 'show'
                action = :read
              when 'new'
                action = :create
              when 'edit'
                action = :update
              else
                action = c.action_name.to_sym
              end

              OSU::AccessPolicy.require_action_allowed!(action,
                c.current_user, c.get_model(options[:id_param],
                                            options[:model_class]))
            end
          end
        end
      end
    end
  end
end

ActionController::Base.send :include, OpenStax::Utilities::ControllerExtensions
