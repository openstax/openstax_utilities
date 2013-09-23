# http://stackoverflow.com/a/1328093/1664216
module Kernel
  def eigenclass
    class << self
      self
    end
  end

  def includes_module?(mod)
    eigenclass.included_modules.include?(mod)
  end
end