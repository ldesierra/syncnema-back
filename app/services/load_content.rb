class LoadContent < ApplicationService
  def initialize(quantity, first_page)
    @quantity = quantity
    @first_page = first_page
  end

  def call
    begin
      (movies, series) = FetchTopRatedContent.call(@quantity, @first_page)

      movies = FetchStreamingSites.call(movies, 'movie')
      series = FetchStreamingSites.call(series, 'tv')

      movies = ImdbTmdbExpand.call('movie', movies)
      series = ImdbTmdbExpand.call('tv', series)

      records_saved = []
    rescue => error
      return puts 'Error fetching movies'
    end

    movies.each do |movie|
      begin
        ActiveRecord::Base.transaction do
          record = Movie.find_or_initialize_by(title: movie['name'])
          attributes = {}

          Content::FIELD_MAPPINGS.each do |mapping_key, mapping_value|
            value = mapping_value.split('/').inject(movie) do |value, operation|
              if value.blank?
                nil
              elsif operation.starts_with?('.')
                value.send(operation.gsub('.', ''))
              else
                value[operation]
              end
            end

            attributes[mapping_key] = value
          end

          attributes[:imdb_id] = movie[:imdb_id]
          attributes[:tmdb_id] = movie[:id]

          record.update!(attributes)
          record.combine_dates
          record.combine_fields('imdb_runtime', 'tmdb_runtime', 'combined_runtime')
          record.combine_fields('budget', 'production_budget', 'combined_budget')
          record.combine_fields('lifetime_gross', 'revenue', 'combined_revenue')

          movie[:streaming_sites]&.each do |kind, value|
            next if kind == 'link'

            value.each do |site|
              streaming_site = StreamingSite.find_or_create_by(
                kind: kind,
                name: site['provider_name'],
                image_url: "https://image.tmdb.org/t/p/w500#{site['logo_path']}"
              )

              ContentStreamingSite.create!(
                content: record,
                streaming_site: streaming_site
              )
            end
          end

          records_saved << { id: record.id, data: movie['cast']['edges'] }
        end
      rescue => error
        binding.pry

        puts "Error fetching movie #{movie['name']}"
        next
      end
    end

    series.each do |serie|
      begin
        ActiveRecord::Base.transaction do
          record = Serie.find_or_initialize_by(title: serie['name'])
          attributes = {}

          Content::FIELD_MAPPINGS.each do |mapping_key, mapping_value|
            value = mapping_value.split('/').inject(serie) do |value, operation|
              if value.blank?
                nil
              elsif operation.starts_with?('.')
                value.send(operation.gsub('.', ''))
              else
                value[operation]
              end
            end
            attributes[mapping_key] = value
          end

          attributes[:imdb_id] = serie[:imdb_id]
          attributes[:tmdb_id] = serie[:id]

          record.update!(attributes)
          record.combine_dates
          record.combine_fields('imdb_runtime', 'tmdb_runtime', 'combined_runtime')
          record.combine_fields('budget', 'production_budget', 'combined_budget')
          record.combine_fields('lifetime_gross', 'revenue', 'combined_revenue')

          serie[:streaming_sites]&.each do |kind, value|
            next if kind == 'link'

            value.each do |site|
              streaming_site = StreamingSite.find_or_create_by(
                kind: kind,
                name: site['provider_name'],
                image_url: "https://image.tmdb.org/t/p/w500#{site['logo_path']}"
              )

              ContentStreamingSite.create!(
                content: record,
                streaming_site: streaming_site
              )
            end
          end

          records_saved << { id: record.id, data: serie['cast']['edges'] }
        end
      rescue => error
        binding.pry
        puts "Error fetching serie #{serie['name']}"
        next
      end
    end

    records_saved.each do |saved|
      ChatgptQueriesJob.perform_async(saved[:id])
      CastMemberInfoRetrievalJob.perform_async(saved[:id], saved[:data])
    end
  end
end
