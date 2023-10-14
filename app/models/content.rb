class Content < ApplicationRecord
  validates_presence_of :title, :imdb_id, :tmdb_id

  has_many :ratings
end
