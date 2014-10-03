# Dummy handler for testing the general keyword search

class UsersSearch < OpenStax::Utilities::AbstractKeywordSearchHandler
  self.search_routine = SearchUsers
  self.max_items = 10
  self.min_characters = 3

  def authorized?
    true
  end
end
