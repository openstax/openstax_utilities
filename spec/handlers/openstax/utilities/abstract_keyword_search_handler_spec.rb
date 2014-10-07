require 'rails_helper'

module OpenStax
  module Utilities
    describe AbstractKeywordSearchHandler do

      let!(:users_search) { UsersSearch.new }

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
      end

      it "passes its params to the search routine and sets the total_count output" do
        outputs = users_search.call(params: {q: 'username:dOe'}).outputs
        total_count = outputs[:total_count]
        items = outputs[:items]
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

        outputs = users_search.call(params: {order_by: 'cReAtEd_At DeSc, iD dEsC',
                                             q: 'username:DoE'}).outputs
        total_count = outputs[:total_count]
        items = outputs[:items]
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
        routine = users_search.call(params: {})
        outputs = routine.outputs
        errors = routine.errors
        expect(outputs).to be_empty
        expect(errors).not_to be_empty
        expect(errors.first.code).to eq :no_query
      end

      it "errors out if the query is too short" do
        routine = users_search.call(params: {q: 'a'})
        outputs = routine.outputs
        errors = routine.errors
        expect(outputs).to be_empty
        expect(errors).not_to be_empty
        expect(errors.first.code).to eq :query_too_short
      end

      it "errors out if too many items match" do
        routine = users_search.call(params: {q: 'username:a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,1,2,3,4,5,6,7,8,9,-,_'})
        outputs = routine.outputs
        errors = routine.errors
        expect(outputs).not_to be_empty
        expect(outputs[:total_count]).to eq User.count
        expect(outputs[:items]).to be_nil
        expect(errors).not_to be_empty
        expect(errors.first.code).to eq :too_many_matches
      end

    end
  end
end
