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
      end

      it "filters results based on one field" do
        items = SearchRelation.call(relation: SearchUsers::RELATION,
                                    search_proc: SearchUsers::SEARCH_PROC,
                                    query: 'last_name:dOe').items

        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        items.each do |item|
          expect(item.name.downcase).to match(/\A[\w]* doe[\w]*\z/i)
        end
      end

      it "filters results based on multiple fields" do
        items = SearchRelation.call(relation: SearchUsers::RELATION,
                                    search_proc: SearchUsers::SEARCH_PROC,
                                    query: 'first_name:jOhN last_name:DoE').items

        expect(items).to include(john_doe)
        expect(items).not_to include(jane_doe)
        expect(items).not_to include(jack_doe)
        items.each do |item|
          expect(item.name).to match(/\Ajohn[\w]* doe[\w]*\z/i)
        end
      end

      it "filters results based on multiple keywords per field" do
        items = SearchRelation.call(relation: SearchUsers::RELATION,
                                    search_proc: SearchUsers::SEARCH_PROC,
                                    query: 'first_name:JoHn,JaNe last_name:dOe').items

        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).not_to include(jack_doe)
        items.each do |item|
          expect(item.name).to match(/\A[john|jane][\w]* doe[\w]*\z/i)
        end
      end

      it "filters scoped results" do
        items = SearchRelation.call(relation: User.where{name.like 'jOhN%'},
                                    search_proc: SearchUsers::SEARCH_PROC,
                                    query: 'last_name:dOe').items

        expect(items).to include(john_doe)
        expect(items).not_to include(jane_doe)
        expect(items).not_to include(jack_doe)
        items.each do |item|
          expect(item.name.downcase).to match(/\Ajohn[\w]* doe[\w]*\z/i)
        end
      end

    end
  end
end
