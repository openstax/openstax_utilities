# Database-agnostic search result limiting and pagination routine
#
# Counts the number of items in a relation and empties it
# if the number exceeds the specified absolute maximum
# Otherwise, applies the specified pagination
#
# Callers of this routine provide the relation argument and
# may provide the max_items, per_page and page arguments
#
# Required arguments:
#
#   Developer-supplied:
#   relation  - the ActiveRecord::Relation to be limited or paginated
#
# Optional arguments:
#
#   Developer-supplied:
#   max_items - the maximum allowed number of search results
#               default: nil (disabled)
#
#   User or developer-supplied:
#   per_page  - the maximum number of search results per page
#               default: nil (disabled)
#   page      - the number of the page to return
#               default: 1
#
# This routine's outputs contain:
#
#   outputs[:total_count] - the total number of items in the relation
#   outputs[:items]       - the original relation after it has
#                           potentially been emptied or paginated

require 'lev'

module OpenStax
  module Utilities
    class LimitAndPaginateRelation

      lev_routine transaction: :no_transaction

      protected

      def exec(relation:, max_items: nil, per_page: nil, page: 1)
        per_page = Integer(per_page) rescue nil
        outputs[:total_count] = relation.count

        if !max_items.nil? && outputs[:total_count] > max_items
          # Limiting
          relation = relation.none
          nonfatal_error(code: :too_many_items,
                         message: "The number of matches exceeded the allowed limit of #{
                           max_items} matches. Please refine your query and try again.")
        elsif !per_page.nil?
          # Pagination
          page = Integer(page) rescue 1
          relation = relation.limit(per_page).offset(per_page*(page-1))
        end

        outputs[:items] = relation
      end

    end

  end
end
