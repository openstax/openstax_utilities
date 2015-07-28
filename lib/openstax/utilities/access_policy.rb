# See the README

module OpenStax
  module Utilities
    class AccessPolicy
      include Singleton

      attr_reader :resource_policy_map

      def initialize()
        @resource_policy_map = {}
      end

      def self.method_missing(method_name, *arguments, &block)
        if method_name.to_s =~ /(.*)_allowed?/
          action_allowed?(*arguments.unshift($1.to_sym), &block)
        else
          super
        end
      end

      def self.respond_to_missing?(method_name, include_private = false)
        method_name.to_s.end_with?('_allowed?') || super
      end

      def self.require_action_allowed!(action, requestor, resource)
        msg = "\"#{requestor.inspect}\" is not allowed to perform \"#{action}\" on \"#{resource.inspect}\""
        raise(SecurityTransgression, msg) unless action_allowed?(action, requestor, resource)
      end

      def self.action_allowed?(action, requestor, resource)

        # If the incoming requestor is an ApiUser, choose to use either its
        # human_user or its application.  If there is a human user involved, it
        # should always take precedence when testing for access.
        if defined?(OpenStax::Api::ApiUser) &&
           requestor.is_a?(OpenStax::Api::ApiUser)
          requestor = requestor.human_user ? requestor.human_user : requestor.application
        end

        resource_class = resource.is_a?(Class) ? resource : resource.class
        policy_class = instance.resource_policy_map[resource_class.to_s].try(:constantize)

        # If there is no policy registered, we by default deny access
        return false if policy_class.nil?

        policy_class.action_allowed?(action, requestor, resource)
      end

      def self.register(resource_class, policy_class)
        self.instance.resource_policy_map[resource_class.to_s] = policy_class.to_s
      end

    end
  end
end
