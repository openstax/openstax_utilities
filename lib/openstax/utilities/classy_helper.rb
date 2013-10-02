module OpenStax::Utilities

  class ClassyHelper < SimpleDelegator

    def initialize(helper_self)
      @helper_self = helper_self
      super(helper_self)
    end

    def true_self
      @helper_self
    end

  end

end