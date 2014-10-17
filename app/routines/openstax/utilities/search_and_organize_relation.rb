# Database-agnostic routine for keyword searching
# and ordering, limiting and paginating search results
#
# Searches, orders, imposes a maximum number or records and paginates
# a given relation using the appropriate routines and user-supplied
# parameters from the params hash
#
# See the search_routine.rb, order_routine.rb and
# limit_and_paginate_routine.rb files for more information
#
# Callers must provide the search_relation, search_proc and
# sortable_fields arguments and may provide the max_items argument
#
# Users must provide the q (query) argument and may provide
# the order_by, per_page and page arguments in the params hash
# Users must also be authorized to search the base class of the search_routine
#
# Required:
#
#   Developer-supplied:
#   relation        - the initial ActiveRecord::Relation to start searching on
#   search_proc     - a Proc passed to keyword_search's `search` method
#                     it receives keyword_search's `with` object as argument
#                     this proc must define the `keyword` blocks for keyword_search
#                     the relation to be scoped is contained in the @items instance variable
#                     the `to_string_array` helper can help with
#                     parsing strings from the query
#   sortable_fields - list of fields that can appear in the order_by argument
#                     can be a Hash that maps field names to database columns
#                     or an Array of Strings
#
#   User or UI-supplied:
#   params[:q]      - a String that follows the keyword format
#                     Keywords have the format keyword:value
#                     Keywords can also be negated with -, as in -keyword:value
#                     Values are comma-separated, while keywords are space-separated
#
# Optional:
#
#   Developer-supplied (recommended to prevent scraping):
#   max_items         - the maximum number of matching items allowed to be returned
#                       no results will be returned if this number is exceeded,
#                       but the total result count will still be returned
#                       applies even if pagination is enabled
#                       default: nil (disabled)
#
#   User or UI-supplied:
#   params[:order_by] - list of fields to order by, with optional sort directions
#                       can be (an Array of) Hashes, or Strings
#                       default: {:created_at => :asc}
#
#   params[:per_page] - the maximum number of search results per page
#                       default: nil (disabled)
#   params[:page]     - the number of the page to return 
#                       default: 1
#
# This handler's output contains:
#
#   outputs[:total_count] - the total number of items that matched the query
#   outputs[:items]       - the relation returned by the search routines

require 'lev'

module OpenStax
  module Utilities
    class SearchAndOrganizeRelation

      lev_routine transaction: :no_transaction

      uses_routine SearchRelation,
                   as: :search
      uses_routine OrderRelation,
                   as: :order
      uses_routine LimitAndPaginateRelation,
                   as: :limit_and_paginate,
                   errors_are_fatal: false,
                   translations: {outputs: {type: :verbatim}}

      protected

      def exec(relation:, search_proc:, sortable_fields:, params:, max_items: nil)
        items = run(:search, relation: relation, search_proc: search_proc,
                    query: params[:q]).outputs[:items]

        items = run(:order, relation: items, sortable_fields: sortable_fields,
                    order_by: params[:order_by]).outputs[:items]

        if max_items.nil? && params[:per_page].nil?
          outputs[:items] = items
          outputs[:total_count] = items.count
          return
        end

        run(:limit_and_paginate, relation: items, max_items: max_items,
            per_page: params[:per_page], page: params[:page])
      end

    end

  end
end
