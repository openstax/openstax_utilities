# Routine for general keyword searching
#
# Keywords have the format keyword:value
# Keywords can also be negated with -, as in -keyword:value
# Values are comma-separated, while keywords are space-separated
# See https://github.com/bruce/keyword_search for more information
#
# Subclasses must set the initial_relation, search_proc and sortable_fields class variables
#
# Required:
#
#   initial_relation is the ActiveRecord::Relation that contains
#   all records to be searched, usually ClassName.unscoped
#
#   search_proc is a lambda that is passed 2 arguments:
#     The first argument is the `with` object from keyword_search
#     The second argument contains the relation to be scoped based on the search query
#   The search_proc must define the `keyword` blocks for keyword_search
#
#   sortable_fields_map is a Hash that maps the lowercase names of fields that can
#   be used to sort the results to symbols for their respective database columns
#     Keys are lowercase strings allowed in options[:order_by]
#     Values are the corresponding database column names passed to the order() method
#
# Callers of subclass routines provides a query argument and an options hash
#
#   The query is a string that follows the keyword format above
#
#   The options hash can have any of several available options:
#
#     Ordering:
#
#       :order_by - list of fields to sort by, with optional sort directions
#                   can be a String, Array of Strings or Array of Hashes
#                   (default: {"created_at" => :asc})
#
#     Pagination - set per_page to enable:
#
#       :per_page - the maximum number of results per page (default: nil)
#       :page     - the page to return (default: 1)
#
# This routine's output contains:
#
#   outputs[:items] - an ActiveRecord::Relation that matches the query terms and options
#
# You can obtain the total count of records that matched the query terms like so:
#
#   outputs[:items].limit(nil).count

module OpenStax
  module Utilities
    class KeywordSearch

      lev_routine transaction: :no_transaction

      protected

      class_attribute :initial_relation, :search_proc, :sortable_fields_map

      def exec(query, options = {})
        raise NotImplementedError if initial_relation.nil? || \
          search_proc.nil? || sortable_fields_map.nil?

        items = initial_relation

        return items.none unless query.is_a? String

        # Scoping

        KeywordSearch.search(query) do |with|
          search_proc.call(with, items)
        end

        # Ordering

        order_bys = sanitize_order_bys(options[:order_by])
        items = items.order(order_bys)
        
        # Pagination

        per_page = Integer(options[:per_page]) rescue nil
        unless per_page.nil?
          page = Integer(options[:page]) rescue 1
          items = items.limit(per_page).offset(per_page*(page-1))
        end

        outputs[:items] = items
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

    end

  end
end
