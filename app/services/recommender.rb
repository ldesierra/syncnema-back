class Recommender < ApplicationService
  def initialize(user)
    @user = user
  end

  def call
    send("recommender_for_#{Rails.env}")
  end

  def recommender_for_production
    positive_user_ratings = @user.ratings.positive.order(score: :desc)
    negative_user_ratings = @user.ratings.negative.order(score: :asc)

    rated_content_id = (positive_user_ratings + negative_user_ratings).pluck(:content_id)

    positive_ratings_to_positive_movies = Rating.where.not(user: @user).where(
      content_id: positive_user_ratings.pluck(:content_id)
    )
    negative_ratings_to_negative_movies = Rating.where.not(user: @user).where(
      content_id: negative_user_ratings.pluck(:content_id)
    )

    matching_ratings = (negative_ratings_to_negative_movies + positive_ratings_to_positive_movies)
    grouped_ratings = matching_ratings.group_by(&:user_id)
                                      .sort_by { |user_id, ratings| -ratings.length }

    similar_user_ids = grouped_ratings.map{ |s| s.first }

    final_rating_ids = []

    similar_user_ids.each do |similar_user_id|
      rating_ids = Rating.where.not(content_id: rated_content_id)
                         .where(user_id: similar_user_id)
                         .positive
                         .pluck(:id, :content_id)

      final_rating_ids += rating_ids
    end

    final_rating_ids = final_rating_ids.uniq { |rating| rating.second }.first(20)

    recommended_content = Rating.find(final_rating_ids.map(&:first))
                                .sort_by { |rating| -rating.score }
                                .pluck(:content_id)

    Content.where(id: recommended_content).first(20)
  end

  def recommender_for_development
    recommender = Disco::Recommender.new

    data = Rating.all.map do |rating|
      { user_id: rating.user_id, item_id: rating.content_id, rating: rating.score }
    end

    result = nil

    begin
      recommender.fit(data)
      result = recommender.user_recs(@user.id).sort_by { |s| - s[:score] }
    rescue
      puts 'Error recommending'
    end

    return result.presence
  end
end
