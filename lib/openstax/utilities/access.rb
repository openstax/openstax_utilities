ActionController::Base.define_singleton_method(:protect_beta) do |options={}|
  options[:username] ||= SecureRandom.hex
  options[:password] ||= SecureRandom.hex
  options[:enable_always] ||= false
  options[:message] ||= ''
  
  return if !(options[:enable_always] || Rails.env.production?)

  @@protect_beta_options = options
  prepend_before_filter :protect_beta
end

ActionController::Base.define_singleton_method(:skip_protect_beta) do |options={}|
  skip_before_filter :protect_beta, options
end

class ActionController::Base
  def protect_beta
    options = @@protect_beta_options
    authenticate_or_request_with_http_basic(options[:message]) do |username, password|
      username == options[:username] && password == options[:password]
    end
  end
end

module OpenStax
  module Utilities
    module Access

      # Called in a controller to provide an outer level of basic HTTP 
      # authentication, typically used when code is deployed during development
      # and it is not yet ready for public consumption.
      #
      # @example Basic usage
      #   class ApplicationController < ActionController::Base
      #     protect_beta :username => 'bob',
      #                  :password => '123'
      #
      # @param :username The authentication username; default value is a random hex string
      # @param :password The authentication password; default value is a random hex string
      # @param :enable_always The default is the authentication is only enabled
      #   in production, setting this to true will make it effective in all 
      #   environments
      # @param :message If given, this message will be displayed in the browser's
      #   authentication dialog box.
      #
      def self.protect_beta(options={})
        # Just here for documentation purposes, see code above
      end

      # Called in a controller to skip the beta protection enabled elsewhere (e.g.
      # in a parent controller).  Takes options like skip_before_filter
      #
      # @example Usage to skip beta protection on index action
      #   class MyController < ApplicationController
      #     skip_protect_beta :except => [:index]
      #
      # @param :except Methods to not use this skip for
      # @param :only The only methods to use this skipping
      #
      def self.skip_protect_beta(options={})
        # Just here for documentation purposes, see code above
      end

    end
  end
end
