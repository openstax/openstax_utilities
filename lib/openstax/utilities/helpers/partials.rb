module OpenStax::Utilities::Helpers
  module Partials

    def block_to_partial(partial_name, options={}, &block)
      options.merge!(:body => capture(&block))
      render(:partial => partial_name, :locals => options)
    end

  end
end