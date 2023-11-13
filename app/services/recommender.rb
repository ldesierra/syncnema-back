class Recommender < ApplicationService
  def initialize(user)
    @user = user
  end

  def metric(first, second)
    highest = first > second ? first : second

    ((((first + second) / (highest * 2).to_f) - 0.5) * 2)
  end

  def call
    user_ratings = @user.ratings
    rating_hash = user_ratings.to_h { |rated| [rated.content_id, rated.score] }

    rated_content_id = user_ratings.pluck(:content_id)

    ratings_to_rated_movies = Rating.where.not(user: @user).where(
      content_id: rated_content_id
    )

    grouped_ratings = ratings_to_rated_movies.group_by(&:user_id)
    grouped_ratings = grouped_ratings.map do |group|
      group_value = group.second.map do |rating|
        { rating_id: rating.id, score: metric(rating.score, rating_hash[rating.content_id]) }
      end

      { group.first => group_value }
    end

    grouped_with_total = grouped_ratings.map do |group|
      group.merge!(total: group.values.first.inject(0) { |sum, rating| sum + rating[:score] })
    end
    sorted_by_similarity = grouped_ratings.sort_by { |group| -group[:total] }

    similar_users = sorted_by_similarity.map{ |s| [s.first.first, s.values.second] }
    final_rating_ids = []

    final_rating_ids = similar_users.flat_map do |similar_user_id, score|
      recommended = Rating.where.not(content_id: rated_content_id)
                          .where(user_id: similar_user_id)
                          .positive
                          .pluck(:id, :content_id, :score)

      recommended.map! { |rating| [rating.first, rating.second, rating.third + score] }
    end

    final_rating_ids = final_rating_ids.sort_by { |rating| -rating.third }
                                       .uniq { |rating| rating.second }
                                       .first(20)

    recommended_content = Rating.find(final_rating_ids.map(&:first))
                                .pluck(:content_id)

    result = Content.where(id: recommended_content)
    result = if result.size == 20
               result
             else
              result + Content.where.not(id: result.pluck(:id)).first(20 - result.size)
             end

    result.pluck(:id, :title, :image_url, :type)
  end

  # def recommender_for_development
  #   recommender = Disco::Recommender.new

  #   data = Rating.all.map do |rating|
  #     { user_id: rating.user_id, item_id: rating.content_id, rating: rating.score }
  #   end

  #   result = nil

  #   begin
  #     recommender.fit(data)
  #     result = recommender.user_recs(@user.id, count: 20).sort_by { |s| - s[:score] }
  #   rescue
  #     puts 'Error recommending'
  #   end

  #   return result.presence
  # end
end
