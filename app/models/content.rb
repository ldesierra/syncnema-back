class Content < ApplicationRecord
  include Searchable

  validates_presence_of :title, :imdb_id, :tmdb_id

  has_many :favourites, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :streaming_sites, dependent: :destroy
  has_many :cast_member_contents, dependent: :destroy
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
    director: 'director/.first/name',
    creator: 'creator'
  }

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, type: 'text'
      #indexes :adult, type: 'keyword'
    end
  end

  def combine_dates
    self.combined_release_date = release_date_imdb if release_date_tmdb.blank?
    self.combined_release_date = release_date_tmdb if release_date_imdb.blank?

    if release_date_tmdb.present? && release_date_imdb.present?
      imdb_date = release_date_imdb.to_date
      tmdb_date = release_date_tmdb.to_date

      if imdb_date > tmdb_date
        difference = imdb_date - tmdb_date
        midpoint_difference = difference / 2
        self.combined_release_date = imdb_date - midpoint_difference.days
      else
        difference = tmdb_date - imdb_date
        midpoint_difference = difference / 2
        self.combined_release_date = tmdb_date - midpoint_difference.days
      end
    end

    save!
  end

  def combine_fields(field_1, field_2, combined_field)
    self.send("#{combined_field}=", send(field_1)) if send(field_2).blank?
    self.send("#{combined_field}=", send(field_2)) if send(field_1).blank?

    if send(field_2).present? && send(field_2).present?
      if send(field_1) > send(field_2)
        self.send("#{combined_field}=", send(field_1) - ((send(field_1) - send(field_2)) / 2))
      else
        self.send("#{combined_field}=", send(field_2) - ((send(field_2) - send(field_1)) / 2))
      end
    end

    save!
  end

  def combine_genres
  end

  def combine_plots
  end
end
