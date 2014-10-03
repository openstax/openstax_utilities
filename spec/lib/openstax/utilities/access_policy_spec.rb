require 'rails_helper'

module OpenStax
  module Utilities

    describe AccessPolicy do

      let!(:user) { FactoryGirl.create :user }

      it 'responds to any _allowed? calls' do
        AccessPolicy.register(User, DummyAccessPolicy)

        DummyAccessPolicy.last_action = nil
        DummyAccessPolicy.last_requestor = nil
        DummyAccessPolicy.last_resource = nil

        expect(AccessPolicy.respond_to? :wacky_allowed?).to eq(true)
        expect(AccessPolicy.wacky_allowed?(user, user)).to eq(true)

        expect(DummyAccessPolicy.last_action).to eq(:wacky)
        expect(DummyAccessPolicy.last_requestor).to eq(user)
        expect(DummyAccessPolicy.last_resource).to eq(user)
      end

      it 'delegates checks to policy classes based on resource class' do
        dummy_object = double('Dummy')
        dummy_policy = double('Dummy Policy', :action_allowed? => true)

        AccessPolicy.register(User, DummyAccessPolicy)
        AccessPolicy.register(dummy_object.class, dummy_policy)
        
        DummyAccessPolicy.last_action = nil
        DummyAccessPolicy.last_requestor = nil
        DummyAccessPolicy.last_resource = nil

        expect(AccessPolicy.action_allowed?(:read, user, dummy_object)).to(
          eq(true))
      
        expect{AccessPolicy.require_action_allowed!(:read, user, dummy_object)
          }.not_to raise_error

        expect(DummyAccessPolicy.last_action).to be_nil
        expect(DummyAccessPolicy.last_requestor).to be_nil
        expect(DummyAccessPolicy.last_resource).to be_nil

        expect(AccessPolicy.action_allowed?(:create, user, User.new)).to(
          eq(true))

        expect{AccessPolicy.require_action_allowed!(:create, user, User.new)
          }.not_to raise_error

        expect(DummyAccessPolicy.last_action).to eq(:create)
        expect(DummyAccessPolicy.last_requestor).to eq(user)
        expect(DummyAccessPolicy.last_resource).to be_instance_of(User)
        expect(DummyAccessPolicy.last_resource.id).to be_nil
      end

      it 'denies permission if the policy class is not registered' do
        expect(OSU::AccessPolicy.action_allowed?(:destroy, user, Object)).to eq(false)

        expect{OSU::AccessPolicy.require_action_allowed!(:destroy, user, Object)}.to raise_error(SecurityTransgression)
      end

    end

  end
end
