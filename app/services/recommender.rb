class Recommender < ApplicationService

  def initialize(user)
    @user = user
  end

  def call
    recommender = Disco::Recommender.new

    data = Rating.all.map do |rating|
      { user_id: rating.user_id, item_id: rating.content_id, rating: rating.score }
    end

    recommender.fit(data)

    return recommender.user_recs(@user.id).sort_by { |s| - s[:score] }
  end
end
