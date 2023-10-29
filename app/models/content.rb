class Content < ApplicationRecord
  include Searchable

  validates_presence_of :title, :imdb_id, :tmdb_id

  has_many :ratings
  has_many :streaming_sites
  has_many :cast_member_contents
  has_many :cast_members, through: :cast_member_contents

  FIELD_MAPPINGS = {
    image_url: 'image',
    content_rating: 'contentRating',
    adult: 'isAdult',
    trailer_url: 'trailer/embedUrl',
    plot: 'plot/plotText/plainText',
    overview: 'overview',
    revenue: 'revenue',
    tmdb_genres: 'tmdb_genres',
    imdb_genres: 'genre',
    lifetime_gross: 'lifetimeGross/total/amount',
    tmdb_runtime: 'tmdb_runtime',
    imdb_runtime: 'runtime/seconds',
    production_budget: 'productionBudget/budget/amount',
    budget: 'budget',
    review_name: 'review/name',
    review_body: 'review/reviewBody',
    rating: 'aggregateRating/ratingValue',
    metacritic: 'metacritic/metascore/score',
    episodes: 'episodes',
    trivia: 'trivia/edges/.first/node/text/plaidHtml',
    quotes: 'quotes/edges/.first/node/lines/.first/text',
    release_date_imdb: 'release_date_imdb',
    release_date_tmdb: 'release_date',
    director: 'director/.first/name'
  }

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, type: 'text'
      indexes :adult, type: 'keyword'
    end
  end
end
