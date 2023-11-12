class Recommender < ApplicationService
  def initialize(user)
    @user = user
  end

  def call
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
