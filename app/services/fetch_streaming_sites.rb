class FetchStreamingSites < ApplicationService
  def initialize(records, kind)
    @records = records
    @kind = kind
  end

  def call
    @records.map do |record|
      request = HTTParty.get("https://api.themoviedb.org/3/#{@kind}/#{record[:id]}/watch/providers", headers: { 'Authorization': ENV['TMDB_AUTH_TOKEN'] })

      parsed_result = providers = JSON.parse(request.body)['results']
      providers = parsed_result['US'] if parsed_result

      record.merge('streaming_sites': providers)
    end
  end
end
