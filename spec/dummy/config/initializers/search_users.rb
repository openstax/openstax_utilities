# Convenience constants for testing the search routines

class SearchUsers
  RELATION = User.unscoped

  SEARCH_PROC = ->(with) do
    with.keyword :username do |names|
      snames = to_string_array(names, append_wildcard: true)
      @items = @items.where(@items.arel_table[:username].matches_any(snames))
    end

    with.keyword :first_name do |names|
      snames = to_string_array(names, append_wildcard: true)
      @items = @items.where(@items.arel_table[:name].matches_any(snames))
    end

    with.keyword :last_name do |names|
      snames = to_string_array(names, append_wildcard: true).map { |name| "% #{name}" }
      @items = @items.where(@items.arel_table[:name].matches_any(snames))
    end
  end

  SORTABLE_FIELDS = {'id' => :id, 'name' => :name, 'created_at' => :created_at}

  MAX_ITEMS = 50
end
