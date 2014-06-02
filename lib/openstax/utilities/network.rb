module OpenStax::Utilities

  def self.generate_url(*urls)
    params = urls.pop if urls.last.is_a? Hash
    uri = URI.join(*urls)
    uri.query = params.to_query if params
    uri.to_s
  end

end
