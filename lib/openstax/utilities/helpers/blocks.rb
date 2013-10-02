# Copyright 2011-2013 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module OpenStax::Utilities::Helpers
  module Blocks

    def section_block(heading=nil, &block)
      presenter = OpenStax::Utilities::Blocks::SectionBlock.new(true_self, heading, block)
    end

    def table_block(&block)
      presenter = TableBlock.new(true_self, block)
    end

    def table_row_block(&block)
      presenter = TableRowBlock.new(true_self, block)
    end

    def table_cell_block(&block)
      presenter = TableCellBlock.new(true_self, block)
    end

  end
end
