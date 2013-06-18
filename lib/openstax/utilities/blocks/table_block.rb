# Copyright 2011-2013 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module OpenStax::Utilities::Blocks
  class TableBlock < BlockBase

    html_element :table
    html_element :caption
    html_element :heading_row
    html_element :heading_cell

    attr_reader :column_names
    attr_reader :row_blocks
    attr_reader :title

    def initialize(template, block)
      super(template, "table", block)
      self.column_names = []
      self.row_blocks   = []

      self.table_class_add "table-block-table"

    end

    def set_title(table_title)
      self.title = table_title
      self
    end

    def title=(table_title)
      raise "TableBlock title cannot be changed once initialized" \
        if @title
      @title = table_title
    end

    def add_column(column_name)
      self.column_names << column_name
      self
    end

    def add_row_block(&block)
      self.row_blocks << h.table_row_block(&block)
      self
    end

    def add_row(*args)
      trb = h.table_row_block do |rb|
        args.each do |arg|
          rb.add_cell(arg)
        end
      end
      self.row_blocks << trb
      self
    end

    def add_section_heading(heading)
      trb = h.table_row_block do |rb|
        rb.set_section_heading(heading, column_names.count)
      end
      self.row_blocks << trb
      self    
    end

    def show_caption?
      title.present?
    end

  protected

    attr_writer :column_names
    attr_writer :row_blocks

  end
end