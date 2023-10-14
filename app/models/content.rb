class Content < ApplicationRecord
  validates_presence_of :title, :imdb_id, :tmdb_id
end
