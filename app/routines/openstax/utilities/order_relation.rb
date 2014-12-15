# Database-agnostic search result ordering routine
#
# Performs ordering of search results
#
# Callers of this routine provide the relation,
# sortable_fields and order_by arguments
#
# Required arguments:
#
#   Developer-supplied:
#
#   relation        - the ActiveRecord::Relation to be ordered
#
#   sortable_fields - list of fields that can appear in the order_by argument
#                     can be a Hash that maps field names to database columns
#                     or an Array of Strings
#                     invalid fields in order_by will be replaced with
#                     the first field listed here, in :asc order
#
# Optional arguments:
#
#   User or developer-supplied:
#
#   order_by        - list of fields to order by, with optional sort directions
#                     can be (an Array of) Hashes, or Strings
#                     default: {sortable_fields.values.first => :asc}
#
# This routine's outputs contain:
#
#   outputs[:items] - a relation containing the ordered records

require 'lev'

module OpenStax
  module Utilities
    class OrderRelation

      lev_routine transaction: :no_transaction

      protected

      def exec(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        relation = options[:relation] || args[0]
        sortable_fields = options[:sortable_fields] || args[1]
        order_by = options[:order_by] || args[2]

        raise ArgumentError, 'You must specify a :relation option' \
          if relation.nil?
        raise ArgumentError, 'You must specify a :sortable_fields option' \
          if sortable_fields.nil?

        # Convert sortable_fields to Hash if it's an Array
        sortable_fields = Hash[*sortable_fields.collect{|s| [s.to_s, s]}] \
          if sortable_fields.is_a? Array

        # Ordering
        order_bys = sanitize_order_bys(sortable_fields, order_by)
        outputs[:items] = relation.order(order_bys)
      end

      # Returns an order_by Object
      def sanitize_order_by(sortable_fields, field = nil, dir = nil)
        sanitized_field = sortable_fields[field.to_s.downcase] || \
                            sortable_fields.values.first
        sanitized_dir = dir.to_s.downcase == 'desc' ? :desc : :asc
        case sanitized_field
        when Symbol
          {sanitized_field => sanitized_dir}
        when Arel::Attributes::Attribute
          sanitized_field.send sanitized_dir
        else
          "#{sanitized_field.to_s} #{sanitized_dir.to_s.upcase}"
        end
      end

      # Returns an Array of order_by Objects
      def sanitize_order_bys(sortable_fields, order_bys = nil)
        obs = case order_bys
        when Array
          order_bys.collect do |ob|
            case ob
            when Hash
              sanitize_order_by(sortable_fields, ob.keys.first, ob.values.first)
            when Array
              sanitize_order_by(sortable_fields, ob.first, ob.second)
            else
              sanitize_order_by(sortable_fields, ob)
            end
          end
        when Hash
          order_bys.collect { |k, v| sanitize_order_by(sortable_fields, k, v) }
        else
          order_bys.to_s.split(',').collect do |ob|
            fd = ob.split(' ')
            sanitize_order_by(sortable_fields, fd.first, fd.second)
          end
        end
        obs.blank? ? sanitize_order_by(sortable_fields) : obs
      end

    end

  end
end
