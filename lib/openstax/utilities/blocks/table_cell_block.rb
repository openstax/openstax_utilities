# Copyright 2011-2013 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module OpenStax::Utilities::Blocks
  class TableCellBlock < BlockBase

    html_element :td

    def initialize(template, block)
      super(template, "table_cell", block)
    end

    def self.from_value(template, value)
      tcb = TableCellBlock.new(template, Proc.new {})
      tcb.captured_block = value
      tcb
    end

    def set_section_heading(colspan)
      self.td_class_add "section-heading"
      self.td_colspan_add colspan
      self
    end

  end
end