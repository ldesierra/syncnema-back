class Content < ApplicationRecord
  validates_presence_of :title, :imdb_id, :tmdb_id

  has_many :ratings
  has_many :streaming_sites

  FIELD_MAPPINGS = {
    image_url: 'image',
    content_rating: 'contentRating',
    adult: 'isAdult',
    trailer_url: 'trailer/embedUrl',
  }
end
