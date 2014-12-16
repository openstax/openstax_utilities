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
# Required arguments:
#
#   Developer-supplied:
#
#   relation        - the initial ActiveRecord::Relation to start searching on
#   search_proc     - a Proc passed to keyword_search's `search` method
#                     it receives keyword_search's `with` object as argument
#                     this proc must define the `keyword` blocks for keyword_search
#                     the relation to be scoped is contained in the @items instance variable
#                     the `to_string_array` helper can help with
#                     parsing strings from the query
#
#   sortable_fields - list of fields that can appear in the order_by argument
#                     can be a Hash that maps field names to database columns
#                     or an Array of Strings
#                     invalid fields in order_by will be replaced with
#                     the first field listed here, in :asc order
#
#   User or UI-supplied:
#
#   params[:query]  - a String that follows the keyword format
#                     Keywords have the format keyword:value
#                     Keywords can also be negated with -, as in -keyword:value
#                     Values are comma-separated; keywords are space-separated
#
# Optional arguments:
#
#   Developer-supplied (recommended to prevent scraping):
#
#   max_items         - the maximum number of matching items allowed to be returned
#                       no results will be returned if this number is exceeded,
#                       but the total result count will still be returned
#                       applies even if pagination is enabled
#                       default: nil (disabled)
#
#   User or UI-supplied:
#
#   params[:order_by] - list of fields to order by, with optional sort directions
#                       can be (an Array of) Hashes, or Strings
#                       default: {sortable_fields.values.first => :asc}
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
                   translations: { inputs: { type: :verbatim },
                                   outputs: { type: :verbatim } }

      protected

      def exec(*args, &search_proc)

        options = args.last.is_a?(Hash) ? args.pop : {}
        relation = options[:relation] || args[0]
        sortable_fields = options[:sortable_fields] || args[1]
        params = options[:params] || args[2]
        search_proc ||= options[:search_proc] || args[3]
        max_items = options[:max_items] || nil

        raise ArgumentError, 'You must specify a :relation option' \
          if relation.nil?
        raise ArgumentError, 'You must specify a :sortable_fields option' \
          if sortable_fields.nil?
        raise ArgumentError, 'You must specify a :params option' if params.nil?
        raise ArgumentError, 'You must specify a block or :search_proc option' \
          if search_proc.nil?

        query = params[:query] || params[:q]
        order_by = params[:order_by] || params[:ob]
        per_page = params[:per_page] || params[:pp]
        page = params[:page] || params[:p]

        items = run(:search, relation: relation, search_proc: search_proc,
                    query: query).outputs[:items]

        items = run(:order, relation: items, sortable_fields: sortable_fields,
                    order_by: order_by).outputs[:items]

        if max_items.nil? && per_page.nil? && page.nil?
          outputs[:items] = items
          outputs[:total_count] = items.count
          return
        end

        run(:limit_and_paginate, relation: items, max_items: max_items,
            per_page: per_page, page: page)
      end

    end

  end
end
