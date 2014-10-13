require 'rails_helper'

module OpenStax
  module Utilities
    describe KeywordSearchHandler do

      options = {
        caller: FactoryGirl.create(:user),
        search_routine: SearchUsers,
        search_relation: User.unscoped,
        max_items: 10,
        min_characters: 3
      }

      let!(:john_doe) { FactoryGirl.create :user, name: "John Doe",
                                           username: "doejohn",
                                           email: "john@doe.com" }

      let!(:jane_doe) { FactoryGirl.create :user, name: "Jane Doe",
                                           username: "doejane",
                                           email: "jane@doe.com" }

      let!(:jack_doe) { FactoryGirl.create :user, name: "Jack Doe",
                                           username: "doejack",
                                           email: "jack@doe.com" }

      before(:each) do
        100.times do
          FactoryGirl.create(:user)
        end

        DummyAccessPolicy.last_action = nil
        DummyAccessPolicy.last_requestor = nil
        DummyAccessPolicy.last_resource = nil
      end

      it "passes its params to the search routine and sets the total_count output" do
        outputs = KeywordSearchHandler.call(options.merge(
                                              params: {q: 'username:dOe'})).outputs
        total_count = outputs[:total_count]
        items = outputs[:items]
        expect(DummyAccessPolicy.last_action).to eq :search
        expect(DummyAccessPolicy.last_requestor).to eq options[:caller]
        expect(DummyAccessPolicy.last_resource).to eq User
        expect(total_count).to eq items.count
        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        john_index = items.index(john_doe)
        jane_index = items.index(jane_doe)
        jack_index = items.index(jack_doe)
        expect(jane_index).to be > john_index
        expect(jack_index).to be > jane_index
        items.each do |item|
          expect(item.username).to match(/\Adoe[\w]*\z/i)
        end

        DummyAccessPolicy.last_action = nil
        DummyAccessPolicy.last_requestor = nil
        DummyAccessPolicy.last_resource = nil
        outputs = KeywordSearchHandler.call(options.merge(
                                              params: {order_by: 'cReAtEd_At DeSc, iD dEsC',
                                                     q: 'username:DoE'})).outputs
        total_count = outputs[:total_count]
        items = outputs[:items]
        expect(DummyAccessPolicy.last_action).to eq :search
        expect(DummyAccessPolicy.last_requestor).to eq options[:caller]
        expect(DummyAccessPolicy.last_resource).to eq User
        expect(total_count).to eq items.count
        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        john_index = items.index(john_doe)
        jane_index = items.index(jane_doe)
        jack_index = items.index(jack_doe)
        expect(jane_index).to be < john_index
        expect(jack_index).to be < jane_index
        items.each do |item|
          expect(item.username).to match(/\Adoe[\w]*\z/i)
        end
      end

      it "errors out if no query is provided" do
        routine = KeywordSearchHandler.call(options.merge(params: {}))
        outputs = routine.outputs
        errors = routine.errors
        expect(DummyAccessPolicy.last_action).to eq :search
        expect(DummyAccessPolicy.last_requestor).to eq options[:caller]
        expect(DummyAccessPolicy.last_resource).to eq User
        expect(outputs).to be_empty
        expect(errors).not_to be_empty
        expect(errors.first.code).to eq :query_blank
      end

      it "errors out if the query is too short" do
        routine = KeywordSearchHandler.call(options.merge(params: {q: 'a'}))
        outputs = routine.outputs
        errors = routine.errors
        expect(DummyAccessPolicy.last_action).to eq :search
        expect(DummyAccessPolicy.last_requestor).to eq options[:caller]
        expect(DummyAccessPolicy.last_resource).to eq User
        expect(outputs).to be_empty
        expect(errors).not_to be_empty
        expect(errors.first.code).to eq :query_too_short
      end

      it "errors out if too many items match" do
        routine = KeywordSearchHandler.call(options.merge(
                                              params: {
                                                q: 'username:a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,1,2,3,4,5,6,7,8,9,-,_'
                                              }))
        outputs = routine.outputs
        errors = routine.errors
        expect(DummyAccessPolicy.last_action).to eq :search
        expect(DummyAccessPolicy.last_requestor).to eq options[:caller]
        expect(DummyAccessPolicy.last_resource).to eq User
        expect(outputs).not_to be_empty
        expect(outputs[:total_count]).to eq User.count
        expect(outputs[:items]).to be_nil
        expect(errors).not_to be_empty
        expect(errors.first.code).to eq :too_many_items
      end

    end
  end
end
