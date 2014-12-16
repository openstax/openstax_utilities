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
#
#   relation  - the ActiveRecord::Relation to be limited or paginated
#
# Optional arguments:
#
#   Developer-supplied:
#
#   max_items - the maximum allowed number of search results
#               default: nil (disabled)
#
#   User or developer-supplied:
#
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

      def exec(*args)

        options = args.last.is_a?(Hash) ? args.pop : {}
        relation = options[:relation] || args[0]
        max_items = options[:max_items] || nil
        per_page = Integer(options[:per_page]) rescue nil
        page = Integer(options[:page]) rescue 1

        raise ArgumentError, 'You must specify a :relation option' \
          if relation.nil?

        fatal_error(offending_inputs: :per_page,
                    message: 'Invalid page size',
                    code: :invalid_per_page) if !per_page.nil? && per_page < 1
        fatal_error(offending_inputs: :page,
                    message: 'Invalid page number',
                    code: :invalid_page) if page < 1

        outputs[:total_count] = relation.count

        if !max_items.nil? && outputs[:total_count] > max_items
          # Limiting
          relation = relation.none
          nonfatal_error(code: :too_many_items,
                         message: "The number of matches exceeded the allowed limit of #{
                           max_items} matches. Please refine your query and try again.")
        elsif per_page.nil?
          relation = relation.none if page > 1
        else
          # Pagination
          relation = relation.limit(per_page).offset(per_page*(page-1))
        end

        outputs[:items] = relation
      end

    end

  end
end
