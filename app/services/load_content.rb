class LoadContent < ApplicationService
  def initialize(quantity)
    @quantity = quantity
  end

  def call
    begin
      (movies, series) = FetchTopRatedContent.call(@quantity)

      movies = FetchStreamingSites.call(movies, 'movie')
      series = FetchStreamingSites.call(series, 'tv')

      movies = ImdbTmdbExpand.call('movie', movies)
      series = ImdbTmdbExpand.call('tv', series)
    rescue
      return puts 'Error fetching movies'
    end

    begin
      ActiveRecord::Base.transaction do
        movies.each do |movie|
          record = Movie.find_or_initialize_by(title: movie['name'])
          attributes = {}

          Content::FIELD_MAPPINGS.each do |mapping_key, mapping_value|
            value = mapping_value.split('/').inject(movie) do |value, operation|
              return nil if value.blank?
              if operation.starts_with?('.')
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

          movie[:streaming_sites]&.each do |kind, value|
            next if kind == 'link'

            value.each do |site|
              StreamingSite.create!(
                content: record,
                kind: kind,
                name: site['provider_name'],
                image_url: "https://image.tmdb.org/t/p/w500#{site['logo_path']}"
              )
            end
          end

          cast_info = WikidataExpand.call(movie['cast']['edges'].map { |s| s['node']['name']['id'] })

          cast_info.each do |cast_member|
            actor = CastMember.find_or_initialize_by(name: cast_member[:actorName].to_s)
            actor.update(
              occupations: cast_member[:occupation].to_s&.split('|'),
              image: cast_member[:actorImage].to_s,
              awards: cast_member[:actorAwards].to_s&.split('|')
            )

            join = CastMemberContent.find_or_initialize_by(content_id: record.id, cast_member_id: actor.id)
            join.save
          end
        end

        series.each do |serie|
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

          serie[:streaming_sites]&.each do |kind, value|
            next if kind == 'link'

            value.each do |site|
              StreamingSite.create!(
                content: record,
                kind: kind,
                name: site['provider_name'],
                image_url: "https://image.tmdb.org/t/p/w500#{site['logo_path']}"
              )
            end
          end

          cast_info = WikidataExpand.call(serie['cast']['edges'].map { |s| s['node']['name']['id'] })

          cast_info.each do |cast_member|
            actor = CastMember.find_or_initialize_by(name: cast_member[:actorName].to_s)
            actor.update(
              occupations: cast_member[:occupation].to_s&.split('|'),
              image: cast_member[:actorImage].to_s,
              awards: cast_member[:actorAwards].to_s&.split('|')
            )

            join = CastMemberContent.find_or_initialize_by(content_id: record.id, cast_member_id: actor.id)
            join.save
          end
        end
      end
    rescue
      return puts 'Error fetch movies'
    end

    puts 'success'
  end
end
