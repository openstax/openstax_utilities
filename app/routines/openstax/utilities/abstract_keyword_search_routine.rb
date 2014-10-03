# Database-agnostic keyword searching routine
#
# Keywords have the format keyword:value
# Keywords can also be negated with -, as in -keyword:value
# Values are comma-separated, while keywords are space-separated
# See https://github.com/bruce/keyword_search for more information
#
# Subclasses must set the initial_relation, search_proc and sortable_fields class variables
#
#   initial_relation - the ActiveRecord::Relation that contains all
#                      records to be searched, usually ClassName.unscoped
#
#   search_proc - a proc passed to keyword_search's `search` method
#                 it receives keyword_search's `with` object as argument
#                 this proc must define the `keyword` blocks for keyword_search
#                 the relation to be scoped is contained in the @items instance variable
#
#   The `sanitize_names` helper can help with parsing strings from the query
#
#   sortable_fields_map - a Hash that maps the lowercase names of fields
#                         which can be used to sort the results to symbols
#                         for their respective database columns
#                         keys are lowercase strings that should be allowed
#                         in options[:order_by]
#                         values are the corresponding database column names
#                         that will be passed to the order() method
#
# Callers of subclass routines provides a query argument and an options hash
#
# Required arguments:
#
#   query - a string that follows the keyword format above
#
# Options hash:
#
#     Ordering:
#
#       :order_by - list of fields to sort by, with optional sort directions
#                   can be a String, Array of Strings or Array of Hashes
#                   default: {"created_at" => :asc}
#
#     Pagination:
#
#       :per_page - the maximum number of results per page - default: nil (disabled)
#       :page     - the page to return - default: 1
#
# This routine's output contains:
#
#   outputs[:items] - an ActiveRecord::Relation that matches the query terms and options
#
# You can use the following expression to obtain the
# total count of records that matched the query terms:
#
#   outputs[:items].limit(nil).offset(nil).count
#
# See spec/dummy/app/routines/search_users.rb for an example search routine

require 'lev'
require 'keyword_search'

module OpenStax
  module Utilities
    class AbstractKeywordSearchRoutine

      lev_routine transaction: :no_transaction

      protected

      class_attribute :initial_relation, :search_proc, :sortable_fields_map

      def exec(query, options = {})
        raise NotImplementedError if initial_relation.nil? || \
          search_proc.nil? || sortable_fields_map.nil?

        @items = initial_relation

        return @items.none unless query.is_a? String

        # Scoping

        ::KeywordSearch.search(query) do |with|
          instance_exec(with, &search_proc)
        end

        # Ordering

        order_bys = sanitize_order_bys(options[:order_by])
        @items = @items.order(order_bys)
        
        # Pagination

        per_page = Integer(options[:per_page]) rescue nil
        unless per_page.nil?
          page = Integer(options[:page]) rescue 1
          @items = @items.limit(per_page).offset(per_page*(page-1))
        end

        outputs[:items] = @items
      end

      def sanitize_order_by(field, dir = nil)
        sanitized_field = sortable_fields_map[field.to_s.downcase] || :created_at
        sanitized_dir = dir.to_s.downcase == 'desc' ? :desc : :asc
        {sanitized_field => sanitized_dir}
      end

      def sanitize_order_bys(order_bys)
        case order_bys
        when Array
          order_bys.collect do |ob|
            case ob
            when Hash
              sanitize_order_by(ob.keys.first, ob.values.first)
            when Array
              sanitize_order_by(ob.first, ob.second)
            else
              sanitize_order_by(ob)
            end
          end
        when Hash
          order_bys.collect { |k, v| sanitize_order_by(k, v) }
        else
          order_bys.to_s.split(',').collect do |ob|
            fd = ob.split(' ')
            sanitize_order_by(fd.first, fd.second)
          end
        end
      end

      # Parses and sanitizes a keyword string
      # User-supplied wildcards are removed and strings are split on commas
      # Then wildcards are appended or prepended if the append_wildcard or
      # prepend_wildcard options are specified
      def sanitize_names(names, options = {})
        na = case names
        when Array
          names.collect{|name| name.gsub('%', '').split(',')}.flatten
        else
          names.to_s.gsub('%', '').split(',')
        end
        na = na.collect{|name| "#{name}%"} if options[:append_wildcard]
        na = na.collect{|name| "%#{name}"} if options[:prepend_wildcard]
        na
      end

    end

  end
end
