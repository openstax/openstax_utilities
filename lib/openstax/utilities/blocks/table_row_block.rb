# Copyright 2011-2013 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module OpenStax::Utilities::Blocks
  class TableRowBlock < BlockBase

    attr_reader :cell_blocks
    attr_reader :section_heading

    def initialize(template, block)
      super(template, "table_row", block)
      self.cell_blocks     = []
      self.section_heading = false
    end

    def add_cell_block(&block)
      self.cell_blocks << h.table_cell_block(&block)
      self
    end

    def add_cell(value)
      self.cell_blocks << TableCellBlock.from_value(h, value)
    end

    def section_heading?
      section_heading
    end

    def set_section_heading(heading, colspan)
      raise "TableRowBlock cannot be a table section heading if it contains cells" \
        if cell_blocks.any?
      raise "TableRowBlock section heading cannot be changed once initialized" \
        if section_heading?

      tcb = TableCellBlock.from_value(h, heading)
      tcb.set_section_heading(colspan)
      self.cell_blocks << tcb

      self.section_heading = true
      self
    end

  protected

    attr_writer :cell_blocks
    attr_writer :section_heading

  end
end