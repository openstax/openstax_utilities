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

        @relation = User.unscoped
      end

      it "returns nothing if too many results" do
        routine = LimitAndPaginateRelation.call(relation: @relation,
                                                max_items: 10)
        errors = routine.errors
        expect(routine.total_count).to eq User.count
        expect(routine.items).to be_empty
        expect(errors).not_to be_empty
        expect(errors.first.code).to eq :too_many_items
      end

      it "paginates results" do
        all_items = @relation.to_a

        items = LimitAndPaginateRelation.call(relation: @relation,
                                              per_page: 20).items
        expect(items.limit(nil).offset(nil).count).to eq all_items.count
        expect(items.limit(nil).offset(nil).to_a).to eq all_items
        expect(items.count).to eq 20
        expect(items.to_a).to eq all_items[0..19]

        for page in 1..5
          items = LimitAndPaginateRelation.call(relation: @relation,
                                                page: page,
                                                per_page: 20).items
          expect(items.limit(nil).offset(nil).count).to eq all_items.count
          expect(items.limit(nil).offset(nil).to_a).to eq all_items
          expect(items.count).to eq 20
          expect(items.to_a).to eq all_items.slice(20*(page-1), 20)
        end

        items = LimitAndPaginateRelation.call(relation: @relation,
                                              page: 1000,
                                              per_page: 20).items
        expect(items.limit(nil).offset(nil).count).to eq all_items.count
        expect(items.limit(nil).offset(nil).to_a).to eq all_items
        expect(items.count).to eq 0
        expect(items.to_a).to be_empty
      end

    end
  end
end
