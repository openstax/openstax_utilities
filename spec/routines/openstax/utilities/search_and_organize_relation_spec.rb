require 'rails_helper'

module OpenStax
  module Utilities
    describe SearchAndOrganizeRelation do

      OPTIONS = {
        relation: SearchUsers::RELATION,
        search_proc: SearchUsers::SEARCH_PROC,
        sortable_fields: SearchUsers::SORTABLE_FIELDS,
        max_items: SearchUsers::MAX_ITEMS
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
      end

      it "filters results" do
        items = SearchAndOrganizeRelation.call(OPTIONS.merge(params: {
                  q: 'last_name:dOe'})).outputs[:items]

        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        items.each do |item|
          expect(item.name.downcase).to match(/\A[\w]* doe[\w]*\z/i)
        end

        items = SearchAndOrganizeRelation.call(OPTIONS.merge(params: {
                  q: 'first_name:jOhN last_name:DoE'})).outputs[:items]

        expect(items).to include(john_doe)
        expect(items).not_to include(jane_doe)
        expect(items).not_to include(jack_doe)
        items.each do |item|
          expect(item.name).to match(/\Ajohn[\w]* doe[\w]*\z/i)
        end

        items = SearchAndOrganizeRelation.call(OPTIONS.merge(params: {
                  q: 'first_name:JoHn,JaNe last_name:dOe'})).outputs[:items]

        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).not_to include(jack_doe)
        items.each do |item|
          expect(item.name).to match(/\A[john|jane][\w]* doe[\w]*\z/i)
        end
      end

      it "orders results" do
        items = SearchAndOrganizeRelation.call(OPTIONS.merge(params: {
                    order_by: 'cReAtEd_At AsC, iD',
                    q: 'username:dOe'})).outputs[:items].to_a
        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        john_index = items.index(john_doe)
        jane_index = items.index(jane_doe)
        jack_index = items.index(jack_doe)
        expect(jane_index).to be > john_index
        expect(jack_index).to be > jane_index

        items = SearchAndOrganizeRelation.call(OPTIONS.merge(params: {
                  order_by: 'CrEaTeD_aT dEsC, Id DeSc',
                  q: 'username:dOe'})).outputs[:items].to_a
        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        john_index = items.index(john_doe)
        jane_index = items.index(jane_doe)
        jack_index = items.index(jack_doe)
        expect(jane_index).to be < john_index
        expect(jack_index).to be < jane_index
      end

      it "returns nothing if too many results" do
        routine = SearchAndOrganizeRelation.call(OPTIONS.merge(params: {
                    q: ''}))
        outputs = routine.outputs
        errors = routine.errors
        expect(outputs).not_to be_empty
        expect(outputs[:total_count]).to eq User.count
        expect(outputs[:items]).to be_empty
        expect(errors).not_to be_empty
        expect(errors.first.code).to eq :too_many_items
      end

      it "paginates results" do
        all_items = SearchUsers::RELATION.to_a

        items = SearchAndOrganizeRelation.call(OPTIONS
                  .except(:max_items)
                  .merge(params: {q: '',
                                  per_page: 20})).outputs[:items]
        expect(items.limit(nil).offset(nil).count).to eq all_items.length
        expect(items.limit(nil).offset(nil).to_a).to eq all_items
        expect(items.count).to eq 20
        expect(items.to_a).to eq all_items[0..19]

        for page in 1..5
          items = SearchAndOrganizeRelation.call(OPTIONS
                    .except(:max_items)
                    .merge(params: {q: '',
                                    page: page,
                                    per_page: 20})).outputs[:items]
          expect(items.limit(nil).offset(nil).count).to eq all_items.count
          expect(items.limit(nil).offset(nil).to_a).to eq all_items
          expect(items.count).to eq 20
          expect(items.to_a).to eq all_items.slice(20*(page-1), 20)
        end

        items = SearchAndOrganizeRelation.call(OPTIONS
                  .except(:max_items)
                  .merge(params: {q: '',
                                  page: 1000,
                                  per_page: 20})).outputs[:items]
        expect(items.limit(nil).offset(nil).count).to eq all_items.count
        expect(items.limit(nil).offset(nil).to_a).to eq all_items
        expect(items.count).to eq 0
        expect(items.to_a).to be_empty
      end

    end
  end
end
