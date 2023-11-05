class FetchTopRatedContent < ApplicationService
  def initialize(quantity, first_page)
    @quantity = quantity
    @first_page = first_page
  end

  def call
    movies = fetch_content('movie', @first_page)
    series = fetch_content('tv', @first_page)

    return [movies, series]
  end

  def fetch_content(kind, first_page)
    remaining = @quantity
    page = first_page
    result = []

    while remaining > 0
      request = HTTParty.get("https://api.themoviedb.org/3/#{kind}/top_rated?page=#{page}", headers: { 'Authorization': ENV['TMDB_AUTH_TOKEN'] })
      content = JSON.parse(request.body)['results']

      result = result + content.first(remaining > 20 ? 20 : remaining).map {
        |content| content['id']
      }

      remaining = remaining - 20
      page = page + 1
    end

    result.map! do |record|
      request = HTTParty.get("https://api.themoviedb.org/3/#{kind}/#{record}/external_ids", headers: { 'Authorization': ENV['TMDB_AUTH_TOKEN'] })

      { 'id': record, 'imdb_id': request['imdb_id'] }
    end

    result
  end
end
