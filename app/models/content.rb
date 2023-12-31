class Content < ApplicationRecord
  include Searchable

  validates_presence_of :title, :imdb_id, :tmdb_id

  has_many :favourites, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :content_streaming_sites
  has_many :streaming_sites, through: :content_streaming_sites
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
      indexes :type, type: 'text'
      indexes :combined_genres, type: 'text'
      indexes :director, type: 'text'
      indexes :creator, type: 'text'
      indexes :cast_member_contents, type: 'nested' do
        indexes :cast_member, type: 'nested' do
          indexes :name, type: 'text'
        end
      end
      indexes :content_streaming_sites, type: 'nested' do
        indexes :streaming_site, type: 'nested' do
          indexes :name, type: 'text'
        end
      end
    end
  end

  def as_indexed_json(options={})
    {
      id: id,
      image_url: image_url,
      title: title,
      type: type,
      combined_genres: combined_genres,
      director: director,
      creator: creator,
      cast_member_contents: cast_member_contents.map {
        |cmc| { cast_member: { name: cmc.cast_member.name } }
      },
      content_streaming_sites: content_streaming_sites.map {
        |css| { streaming_site: { name: css.streaming_site.name } }
      }
    }
  end

  def combine_dates
    self.combined_release_date = release_date_imdb if release_date_tmdb.blank?
    self.combined_release_date = release_date_tmdb if release_date_imdb.blank?

    if release_date_tmdb.present? && release_date_imdb.present?
      imdb_date = release_date_imdb.to_date
      tmdb_date = release_date_tmdb.to_date

      self.combined_release_date = imdb_date > tmdb_date ? imdb_date : tmdb_date
    end

    save!
  end

  def combine_fields(field_1, field_2, combined_field)
    self.send("#{combined_field}=", send(field_1)) if send(field_2).blank?
    self.send("#{combined_field}=", send(field_2)) if send(field_1).blank?

    if send(field_1).present? && send(field_2).present?
      if send(field_1) > send(field_2)
        self.send("#{combined_field}=", send(field_1) - ((send(field_1) - send(field_2)) / 2))
      else
        self.send("#{combined_field}=", send(field_2) - ((send(field_2) - send(field_1)) / 2))
      end
    end

    save!
  end

  def combine_genres
    self.combined_genres = imdb_genres if tmdb_genres.blank?
    self.combined_genres = tmdb_genres if imdb_genres.blank?

    if tmdb_genres.present? && imdb_genres.present?
      begin
        merged_genres = ChatGpt.call(
          "Merge this two movie genres lists into one with no repetitions or synonims:
          #{tmdb_genres},
          #{imdb_genres}.
          Return only the merged list of genres as a JSON array"
        )
      rescue
        puts 'Error fetching genres'
      end

      begin
        if JSON.parse(merged_genres)&.class&.name == 'Array'
          self.combined_genres = merged_genres
        else
          self.combined_genres = imdb_genres
        end
      rescue
        puts 'JSON Parse Invalid'

        self.combined_genres = imdb_genres
      end
    end

    save!
  end

  def combine_plots
    self.combined_plot = plot if overview.blank?
    self.combined_plot = overview if plot.blank?

    if overview.present? && plot.present?
      begin
        new_plot = ChatGpt.call(
          "You are a very enthusiastic cinephile who loves to combine movie plots from different sites. Given the following movie plots, create another one that merges all the important information. Try to not make it longer than 100 words.
          Plot 1: #{overview}
          Plot 2: #{plot}
          Combined plot:"
        )

        self.combined_plot = new_plot
      rescue
        puts 'ERROR FETCHING PLOT, OUTPUT WAS'
      end

      self.combined_plot = nil if new_plot.blank?
    end

    save!
  end

  def total_rating
    ratings =  Rating.where(content_id: id)
    rating_amount = ratings.count

    rating_sum = ratings.map { |rating| rating.score }.inject(0) { |sum, rating| sum += rating }

    if rating_amount != 0
      rating_sum / rating_amount
    else
      0
    end
  end
end
