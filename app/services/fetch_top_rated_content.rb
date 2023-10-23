class FetchTopRatedContent < ApplicationService
  def initialize(quantity)
    @quantity = quantity
  end

  def call
    movies = fetch_content('movie')
    series = fetch_content('tv')

    return [movies, series]
  end

  def fetch_content(kind)
    remaining = @quantity
    page = 1
    result = []

    while remaining > 0
      request = HTTParty.get("https://api.themoviedb.org/3/#{kind}/top_rated?page=#{page}", headers: { 'Authorization': ENV['TMDB_AUTH_TOKEN'] })
      content = JSON.parse(request.body)['results']

      result = result + content.first(remaining > 20 ? 20 : remaining).map {
        |content| content['id']
      }

      remaining = remaining - 20
    end

    result.map! do |record|
      request = HTTParty.get("https://api.themoviedb.org/3/#{kind}/#{record}/external_ids", headers: { 'Authorization': ENV['TMDB_AUTH_TOKEN'] })

      { 'id': record, 'imdb_id': request['imdb_id'] }
    end

    result
  end
end
