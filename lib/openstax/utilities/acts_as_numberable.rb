# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module OpenStax
  module Utilities

    module ActsAsNumberable

      # Adds code to an ActiveRecord object so that it can be sorted.
      # @example Model is ordered globally using a 'number' field
      #   class MyModel < ActiveRecord::Base
      #     acts_as_numberable
      # @example Model is ordered globally using a 'position' field
      #   class MyModel < ActiveRecord::Base
      #     acts_as_numberable :number_field => :position
      # @example Model is ordered within a container class using a position field
      #   class MyModel < ActiveRecord::Base
      #     belongs_to :other_model
      #     acts_as_numberable :container => :other_model,
      #                        :number_field => :position
      # @param :container The relationship that contains this model in an order.
      #   Note that this code assumes the foreign key for this container is found
      #   by appending "_id" onto the container name, which might not always be the
      #   case.
      # @param :number_field The column to use as the sorting number, given either
      #   as a string or a symbol.  The default is 'number'
      # @param :table_class By default this code assumes that the database table
      #   name to use for this model can be derived from the model's class name; in 
      #   some cases (e.g. STI) this is not the case and this parameter can be used
      #   to manually specify the class from which to derive the database table name.
      #
      def acts_as_numberable(options={})
        configuration = {}
        configuration.update(options) if options.is_a?(Hash)
       
        container_column = nil
        container_column_symbol = nil

        # When calling assign_number below, you normally want to run a query against
        # self.class to figure out what the next available number is; however, if the 
        # class acting as numberable is using STI, self.class will return the child class
        # which is likely not what we want.  In these cases, we can specify the base
        # class here (the class that has the same name as the DB table) so that it is used
        # instead.
        table_class = configuration[:table_class]

        number_field = (configuration[:number_field] || 'number').to_s
        
        if !configuration[:container].nil?
          container_column = configuration[:container].to_s + "_id"
          container_column_symbol = configuration[:container].to_sym
        end
        
        uniqueness_scope_string = container_column.nil? ? "" : ":scope => :#{container_column},"
       
        class_eval <<-EOV
          include ActsAsNumberable::BasicInstanceMethods
        
          before_validation :assign_number, :on => :create
          
          validates :#{number_field}, :uniqueness => { #{uniqueness_scope_string}
                                                       :allow_nil => true},
                                      :numericality => { :only_integer => true, 
                                                         :greater_than_or_equal_to => 0,
                                                         :allow_nil => true }    

          
          after_destroy :mark_as_destroyed
          
          attr_accessor :destroyed
          attr_accessor :changed_sets

          attr_protected :#{number_field}
        
          scope :ordered, order('#{number_field} ASC')
          scope :reverse_ordered, order('#{number_field} DESC')
          
          def self.sort!(sorted_ids)
            return if sorted_ids.blank?
            items = []
            ActiveRecord::Base.transaction do
              items = find_in_specified_order(sorted_ids)
              
              items.each do |item|
                item.send('#{number_field}=', nil)
                item.save!
              end
              
              items.each_with_index do |item, ii| 
                item.send('#{number_field}=', ii)
                item.save!
              end
            end
            items
          end

          def table_class
            #{table_class}
          end

          def number_field
            '#{number_field}'
          end
        EOV
       
       
        if !configuration[:container].nil?
          class_eval <<-EOV
            include ActsAsNumberable::ContainerInstanceMethods
          
            # When we had nested acts_as_numberables, there were cases where the
            # objects were having their numbers changed (as their peers were being
            # removed from the container), but then when it came time to delete those 
            # objects they still had their old number.  So just reload before
            # destroy.
            before_destroy(prepend: true) {self.reload}
          
            after_destroy :remove_from_container!
          
            def container_column
              '#{container_column}'
            end

            def container
              '#{configuration[:container]}'
            end

            def table_class
              #{table_class}
            end
          
          EOV
          
        end
           
      end
       
      module BasicInstanceMethods
        protected

        def my_class
          table_class || self.class
        end

        def assign_number
          self.send("#{number_field}=", my_class.count) if self.send("#{number_field}").nil?
        end
         
        def mark_as_destroyed
          destroyed = true
        end

        def me_and_peers
          my_class.scoped
        end
      end
       
      module ContainerInstanceMethods
        def move_to_container!(new_container)
          return if new_container.id == self.send(container_column)
          ActiveRecord::Base.transaction do
            remove_from_container!

            self.send container + "=", new_container

            self.assign_number
            self.save!
            self.changed_sets = true
          end
        end

        def remove_from_container!
          later_items = my_class.where(container_column => self.send(container_column))
                                .where("#{number_field} > ?", self.send(number_field))

          if !self.destroyed
            self.send "#{number_field}=", nil
            self.send container_column + '=', nil
            self.save!
          end

          # Do this to make sure that the reordering below doesn't 
          # cause a number to be duplicated temporarily (which would
          # cause a validation error)
          later_items.sort_by!{|item| item.send(number_field)}

          later_items.each do |later|
            later.send("#{number_field}=", later.send(number_field)-1)
            later.save!
          end
        end
        
        def my_class
          table_class || self.class
        end

        def me_and_peers
          my_class.where(container_column => self.send(container_column))
        end

        protected
        
        def assign_number
          if self.send(number_field).nil?
            self.send("#{number_field}=", 
                      my_class
                        .where(container_column => self.send(container_column))
                        .count) 
          end
        end
      end
      
    end

  end
end
 
ActiveRecord::Base.extend OpenStax::Utilities::ActsAsNumberable