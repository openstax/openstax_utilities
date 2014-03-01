# Copyright 2011-2014 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module OpenStax
  module Utilities

    module Roar

      def self.included(base)
        base.send :extend, ClassMethods
      end

      def get_representer(represent_with, model=nil)
        return nil if represent_with.nil?
        if represent_with.is_a? Proc
          represent_with.call(model)
        else
          represent_with
        end
      end

      def rest_get(model_klass, id, represent_with=nil)
        @model = model_klass.find(id)
        raise SecurityTransgression unless current_user.can_read?(@model)
        respond_with @model, represent_with: get_representer(represent_with, @model)
      end

      def rest_update(model_klass, id, represent_with=nil)
        @model = model_klass.find(id)
        raise SecurityTransgression unless current_user.can_update?(@model)
        consume!(@model, represent_with: get_representer(represent_with, @model))
        
        if @model.save
          head :no_content
        else
          render json: @model.errors, status: :unprocessable_entity
        end
      end

      def rest_create(model_klass)
        @model = model_klass.new()

        # Unlike the implications of the representable README, "consume!" can
        # actually make changes to the database.  See http://goo.gl/WVLBqA. 
        # We do want to consume before checking the permissions so we can know
        # what we're dealing with, but if user doesn't have permission we don't
        # want to have changed the DB.  Wrap in a transaction to protect ourselves.

        model_klass.transaction do 
          consume!(@model)
          raise SecurityTransgression unless current_user.can_create?(@model)
        end

        if @model.save
          respond_with @model
        else
          render json: @model.errors, status: :unprocessable_entity
        end
      end

      def rest_destroy(model_klass, id)
        @model = model_klass.find(id)
        raise SecurityTransgression unless current_user.can_destroy?(@model)
        
        if @model.destroy
          head :no_content
        else
          render json: @model.errors, status: :unprocessable_entity
        end
      end

      def standard_sort(model_klass)
        # take array of all IDs or hash of id => position,
        # regardless build up an array of all IDs in the right order and pass those to sort

        new_positions = params['newPositions']
        return head :no_content if new_positions.length == 0

        # Can't have duplicate positions or IDs
        unique_ids =       new_positions.collect{|np| np['id']}.uniq
        unique_positions = new_positions.collect{|np| np['position']}.uniq

        return head :bad_request if unique_ids.length != new_positions.length
        return head :bad_request if unique_positions.length != new_positions.length

        first = model_klass.where(:id => new_positions[0]['id']).first

        return head :not_found if first.blank?

        originalOrdered = first.me_and_peers.ordered.all

        originalOrdered.each do |item|
          raise SecurityTransgression unless item.send(:container_column) == originalOrdered[0].send(:container_column) \
            if item.respond_to?(:container_column)
          raise SecurityTransgression unless current_user.can_sort?(item)
        end

        originalOrderedIds = originalOrdered.collect{|sc| sc.id}

        newOrderedIds = Array.new(originalOrderedIds.size)
      
        new_positions.each do |newPosition|
          id = newPosition['id'].to_i
          newOrderedIds[newPosition['position']] = id
          originalOrderedIds.delete(id)
        end

        ptr = 0
        for oldId in originalOrderedIds 
          while !newOrderedIds[ptr].nil?; ptr += 1; end
          newOrderedIds[ptr] = oldId
        end

        begin 
          model_klass.sort!(newOrderedIds)
        rescue Exception => e
          return head :internal_server_error
        end

        head :no_content
      end
      
    end

  end
end