# Copyright 2011-2013 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.
   
require 'attribeautiful'

module OpenStax::Utilities::Blocks 
  class BlockBase
    include Attribeautiful

    attr_accessor :captured_block

    def initialize(template, partial, passed_block)
      self.h            = template
      self.passed_block = passed_block
      self.partial      = partial
    end

    def to_s
      render_passed_block
      render_partial
    end

  protected

    attr_accessor :h
    attr_accessor :passed_block
    attr_accessor :partial

    def render_passed_block
      self.captured_block ||= h.capture self, &passed_block
    end

    def render_partial
      h.render :partial => "osu/shared/#{partial}", :locals => { :block => self }
    end

  end
end