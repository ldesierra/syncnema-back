class ImdbTmdbExpand < ApplicationService
  def initialize(kind, records)
    @kind = kind
    @records = records
  end

  def call
    @records.map do |record|
      request = HTTParty.get("https://api.themoviedb.org/3/#{@kind}/#{record[:id]}?language=en-US", headers: { 'Authorization': ENV['TMDB_AUTH_TOKEN'] })

      data = JSON.parse(request.body)
      record = record.merge(data)

      record.merge!('tmdb_genres' => record['genres'].map {|s| s['name']})
      record.merge!('tmdb_runtime' => record['runtime'])

      request = HTTParty.get("https://search.imdbot.workers.dev/?tt=#{record[:imdb_id]}")

      data = JSON.parse(request.body)
      ['short', 'top', 'main'].each do |sub_hash|
        record = record.merge(data[sub_hash])
      end

      release_date_imdb = "#{record['releaseDate']['year']}-#{record['releaseDate']['month']}-#{record['releaseDate']['day']}"

      begin
        date = release_date_imdb.to_date
        record.merge!('release_date_imdb' => release_date_imdb)
      rescue
        puts 'invalid date'
      end

      creator = record['creator']&.filter { |creator| creator["@type"] == 'Person' }&.last
      record.merge!('creator' => "#{creator['name'] if creator.present?}")

      record
    end
  end
end
