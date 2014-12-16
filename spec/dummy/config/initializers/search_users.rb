# Convenience constants for testing the search routines

class SearchUsers
  RELATION = User.unscoped

  SEARCH_PROC = lambda { |with|
    with.keyword :username do |names|
      snames = to_string_array(names, append_wildcard: true)
      @items = @items.where{username.like_any snames}
    end

    with.keyword :first_name do |names|
      snames = to_string_array(names, append_wildcard: true)
      @items = @items.where{name.like_any snames}
    end

    with.keyword :last_name do |names|
      snames = to_string_array(names, append_wildcard: true).collect{|name| "% #{name}"}
      @items = @items.where{name.like_any snames}
    end
  }

  SORTABLE_FIELDS = {'id' => :id, 'name' => :name, 'created_at' => :created_at}

  MAX_ITEMS = 50
end
