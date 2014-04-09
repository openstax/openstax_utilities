require 'spec_helper'

module OpenStax
  module Utilities
    
    describe ControllerExtensions do

      it 'adds get_model to controllers' do

        expect(ApplicationController.new).to respond_to(:get_model)

        expect(UsersController.new).to respond_to(:get_model)

      end

      it 'adds require_actions_allowed! to controllers' do

        expect(ApplicationController).to(
          respond_to(:require_actions_allowed!))

        expect(UsersController).to respond_to(:require_actions_allowed!)

      end

    end

  end

end