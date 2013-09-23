module OpenStax
  module Utilities
    module Text

      def self.copyright(start_year, holder)
        year_range = "#{start_year}-#{Time.now.year}".sub(/\A(\d+)-\1\z/, '\1');
        "Copyright &copy; #{year_range} #{holder}".html_safe
      end

    end
  end
end