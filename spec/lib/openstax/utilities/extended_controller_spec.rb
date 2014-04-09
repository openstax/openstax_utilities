require 'spec_helper'
    
describe UsersController, :type => :controller do

  let!(:user) { User.create }

  before(:all) do
    UsersController.require_actions_allowed! :except => :index
    OSU::AccessPolicy.register(User, DummyAccessPolicy)
  end

  context 'when user visits restful actions' do

    it 'returns the correct resource with get_model' do
      controller.current_user = user

      get :new
      expect(controller.get_model).to be_instance_of(User)
      expect(controller.get_model.id).to be_nil

      get :show, :id => user.id
      expect(controller.get_model).to eq(user)

      get :new, :user_id => user.id
      expect(controller.get_model(:user_id)).to eq(user)
    end

    it 'calls AccessPolicy with the expected arguments' do
      controller.current_user = user

      DummyAccessPolicy.last_action = nil
      DummyAccessPolicy.last_requestor = nil
      DummyAccessPolicy.last_resource = nil

      get :index

      expect(DummyAccessPolicy.last_action).to be_nil
      expect(DummyAccessPolicy.last_requestor).to be_nil
      expect(DummyAccessPolicy.last_resource).to be_nil

      get :show, :id => user.id

      expect(DummyAccessPolicy.last_action).to eq(:read)
      expect(DummyAccessPolicy.last_requestor).to eq(user)
      expect(DummyAccessPolicy.last_resource).to eq(user)

      get :new

      expect(DummyAccessPolicy.last_action).to eq(:create)
      expect(DummyAccessPolicy.last_requestor).to eq(user)
      expect(DummyAccessPolicy.last_resource).to be_instance_of(User)
      expect(DummyAccessPolicy.last_resource.id).to be_nil

      post :create, :user => user.attributes

      expect(DummyAccessPolicy.last_action).to eq(:create)
      expect(DummyAccessPolicy.last_requestor).to eq(user)
      expect(DummyAccessPolicy.last_resource).to be_instance_of(User)
      expect(DummyAccessPolicy.last_resource.id).to be_nil

      get :edit, :id => user.id, :user => user.attributes

      expect(DummyAccessPolicy.last_action).to eq(:update)
      expect(DummyAccessPolicy.last_requestor).to eq(user)
      expect(DummyAccessPolicy.last_resource).to eq(user)

      put :update, :id => user.id, :user => user.attributes

      expect(DummyAccessPolicy.last_action).to eq(:update)
      expect(DummyAccessPolicy.last_requestor).to eq(user)
      expect(DummyAccessPolicy.last_resource).to eq(user)

      delete :destroy, :id => user.id

      expect(DummyAccessPolicy.last_action).to eq(:destroy)
      expect(DummyAccessPolicy.last_requestor).to eq(user)
      expect(DummyAccessPolicy.last_resource).to eq(user)
    end

  end

end
