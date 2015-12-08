require 'rails_helper'

module OpenStax
  module Utilities
    describe SearchRelation do

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

        @relation = User.where{username.like 'doe%'}
      end

      it "orders results by multiple fields in different directions" do
        items = OrderRelation.call(relation: @relation,
                                   sortable_fields: SearchUsers::SORTABLE_FIELDS,
                                   order_by: 'cReAtEd_At AsC, iD').items
        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        john_index = items.index(john_doe)
        jane_index = items.index(jane_doe)
        jack_index = items.index(jack_doe)
        expect(jane_index).to be > john_index
        expect(jack_index).to be > jane_index

        items = OrderRelation.call(relation: @relation,
                                   sortable_fields: SearchUsers::SORTABLE_FIELDS,
                                   order_by: 'CrEaTeD_aT dEsC, Id DeSc').items
        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        john_index = items.index(john_doe)
        jane_index = items.index(jane_doe)
        jack_index = items.index(jack_doe)
        expect(jane_index).to be < john_index
        expect(jack_index).to be < jane_index
      end

    end
  end
end
