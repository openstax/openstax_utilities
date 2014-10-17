# Database-agnostic keyword searching routine
#
# Filters a relation based on a search Proc and a query String
# See https://github.com/bruce/keyword_search for more information
# about these arguments
#
# Callers of this routine provide the search_proc, relation and query arguments
#
# Required arguments:
#
#   Developer-supplied:
#   relation    - the initial ActiveRecord::Relation to start searching on
#   search_proc - a Proc passed to keyword_search's `search` method
#                 it receives keyword_search's `with` object as argument
#                 this proc must define the `keyword` blocks for keyword_search
#                 the relation to be scoped is contained in the @items instance variable
#                 the `to_string_array` helper can help with
#                 parsing strings from the query
#
#   User or developer-supplied:
#   query       - a String that follows the keyword format
#                 Keywords have the format keyword:value
#                 Keywords can also be negated with -, as in -keyword:value
#                 Values are comma-separated, while keywords are space-separated
#
# This routine's outputs contain:
#
#   outputs[:items] - a relation with records that match the query terms

require 'lev'
require 'keyword_search'

module OpenStax
  module Utilities
    class SearchRelation

      lev_routine transaction: :no_transaction

      protected

      def exec(relation:, search_proc:, query:)

        @items = relation

        # Scoping

        ::KeywordSearch.search(query.to_s) do |with|
          instance_exec(with, &search_proc)
        end

        outputs[:items] = @items
      end

      # Parses a keyword string into an array of strings
      # User-supplied wildcards are removed and strings are split on commas
      # Then wildcards are appended or prepended if the append_wildcard or
      # prepend_wildcard options are specified
      def to_string_array(str, options = {})
        sa = case str
        when Array
          str.collect{|name| name.gsub('%', '').split(',')}.flatten
        else
          str.to_s.gsub('%', '').split(',')
        end
        sa = sa.collect{|str| "#{str}%"} if options[:append_wildcard]
        sa = sa.collect{|str| "%#{str}"} if options[:prepend_wildcard]
        sa
      end

      # Parses a keyword string into an array of numbers
      # User-supplied wildcards are removed and strings are split on commas
      # Only numbers are returned
      def to_number_array(str)
        to_string_array(str).collect{|s| Integer(s) rescue nil}.compact
      end

    end

  end
end
