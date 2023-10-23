class ImdbTmdbExpand < ApplicationService
  def initialize(kind, records)
    @kind = kind
    @records = records
  end

  def call
    @records.map do |record|
      # Expand data with Tmdb
      request = HTTParty.get("https://api.themoviedb.org/3/#{@kind}/#{record[:id]}?language=en-US", headers: { 'Authorization': ENV['TMDB_AUTH_TOKEN'] })

      data = JSON.parse(request.body)
      record = record.merge(data)
      record.merge!(tmdb_genres: record[:genres])
      record.merge!(tmdb_runtime: record[:runtime])

      # Expand data with Imdb
      request = HTTParty.get("https://search.imdbot.workers.dev/?tt=#{record[:imdb_id]}")

      data = JSON.parse(request.body)
      ['short', 'top', 'main'].each do |sub_hash|
        record = record.merge(data[sub_hash])
      end

      record
    end
  end
end
