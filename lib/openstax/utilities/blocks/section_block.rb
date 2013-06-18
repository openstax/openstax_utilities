# Copyright 2011-2013 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module OpenStax::Utilities::Blocks
  class SectionBlock < BlockBase

    html_element :section
    html_element :heading
    html_element :body

    attr_accessor :heading
    attr_accessor :nesting
    attr_accessor :top_bar

    def initialize(template, heading, block)
      super(template, "section", block)

      set_heading(heading) if !heading.blank?
      section_class_add "section-block-section"
      heading_class_add "section-block-heading"
      body_class_add    "section-block-body"
    end

    def set_heading(string)
      self.heading = string
      self
    end

    def set_nesting(depth)
      self.nesting = depth
      self
    end

    def set_top_bar
      raise "SectionBlock top bar cannot be changed once initialized" \
        if @top_bar
      section_class_add "bar-top"
      self.top_bar = true
      self
    end

    def heading=(string)
      raise "SectionBlock heading cannot be changed once initialized" \
        if @heading
      @heading = string
    end

    def nesting=(depth)
      raise "SectionBlock nesting cannot be changed once initialized" \
        if @nesting
      section_class_add "nesting-#{depth}"
      @nesting = depth
    end

    def show_heading?
      heading.present?
    end

  end
end