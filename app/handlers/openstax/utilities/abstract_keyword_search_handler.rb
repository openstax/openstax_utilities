# Database-agnostic keyword searching handler
#
# Keywords have the format keyword:value
# Keywords can also be negated with -, as in -keyword:value
# Values are comma-separated, while keywords are space-separated
# See https://github.com/bruce/keyword_search for more information
#
# Subclasses must set the search_routine class variable,
# as well as the authorized? method
#
# Required:
#
#   search_routine - the Lev::Routine that will handle the search
#
# Optional (recommended to prevent scraping):
#
#   min_characters - the minimum number of characters allowed in the query
#                    only an error will be returned if the query has less
#                    than the minimum number of characters allowed
#                    default: nil (disabled)
#
#   max_items - the maximum number of matching items allowed to be returned
#               no results will be returned if this number is exceeded,
#               but the total result count will still be returned
#               applies even if pagination is enabled
#               default: nil (disabled)
#
# This handler expects the following parameters from the user or the UI:
#
# Required:
#
#   q - the query itself, a String that follows the keyword format above
#
# Optional:
#
#   order_by - a String used to order the search results - default: 'created_at ASC'
#   per_page - the number of results returned per page - default: nil (disabled)
#   page     - the current page number - default: 1
#
# This handler's output contains:
#
#   outputs[:total_count] - the total number of items that matched the query
#                           set even when no results are returned due to
#                           a query that is too short or too generic
#   outputs[:items]       - the array of objects returned by the search routine
#
# See spec/dummy/app/handlers/users_search.rb for an example search handler

require 'lev'

module OpenStax
  module Utilities
    class AbstractKeywordSearchHandler

      lev_handler

      protected

      class_attribute :search_routine, :max_items, :min_characters

      def authorized?
        false
      end

      def handle
        raise NotImplementedError if search_routine.nil?

        query = params[:q] || params[:query]

        fatal_error(code: :no_query,
                    message: 'You must provide a query parameter (q or query).') if query.nil?
        fatal_error(code: :query_too_short,
                    message: "The provided query is too short (minimum #{
                      min_characters} characters).") \
          if !min_characters.nil? && query.length < min_characters

        items = run(search_routine, query, params).outputs[:items]

        outputs[:total_count] = items.limit(nil).offset(nil).count

        fatal_error(code: :too_many_matches,
                    message: "The number of matches exceeded the allowed limit of #{
                      max_items} matches. Please refine your query and try again.") \
          if !max_items.nil? && outputs[:total_count] > max_items

        outputs[:items] = items.to_a
      end

    end

  end
end
