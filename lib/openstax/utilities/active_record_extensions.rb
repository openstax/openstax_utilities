module ActiveRecord
  class Base
       
    def self.find_in_specified_order(ids)
      items = find(ids)

      order_hash = {}
      ids.each_with_index {|id, index| order_hash[id.to_i]=index}

      items.sort_by!{|item| order_hash[item.id]}
    end
    
  end
end