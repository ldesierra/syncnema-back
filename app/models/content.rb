class Content < ApplicationRecord
  include Searchable

  validates_presence_of :title, :imdb_id, :tmdb_id

  has_many :ratings
  has_many :streaming_sites

  FIELD_MAPPINGS = {
    image_url: 'image',
    content_rating: 'contentRating',
    adult: 'isAdult',
    trailer_url: 'trailer/embedUrl',
    plot: 'plot',
    overview: 'overview',
    revenue: 'revenue',
    tmdb_genres: 'tmdb_genres',
    imdb_genres: 'genres',
    lifetime_gross: 'lifetimeGross',
    tmdb_runtime: 'tmdb_runtime',
    imdb_runtime: 'runtime'
  }

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, type: 'text'
      indexes :adult, type: 'keyword'
    end
  end
end
