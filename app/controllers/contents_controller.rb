class ContentsController < ApplicationController
  def show
    content = Content.find_by(id: params[:id])
    user = User.find_by(external_id: params[:user_id])

    return render json: { error: 'Not found' }, status: 404 if content.blank?

    serialized_content = content.slice(
      :trailer_url, :combined_plot, :combined_release_date, :content_rating,
      :combined_runtime, :director, :creator, :title, :combined_genres
    )

    favourite = Favourite.find_by(
      user_id: user&.id, content_id: content.id
    ).present?
    serialized_content.merge!(favourite: favourite)

    rating = Rating.find_by(
      user_id: user&.id, content_id: content.id
    )&.score
    serialized_content = serialized_content.merge!(user_rating: rating)

    cast = CastMemberContent.where(content_id: content.id).map(&:cast_member).map do |member|
      {
        name: member.name,
        image: member.image
      }
    end

    sites = ContentStreamingSite.where(content_id: content.id).map(&:streaming_site)

    streaming_sites = sites.map do |site|
      {
        name: site.name,
        image: site.image_url
      }
    end

    serialized_content.merge!(total_rating: content.total_rating)
    serialized_content.merge!(cast: cast)
    serialized_content.merge!(platforms: streaming_sites)

    render json: serialized_content, status: 200
  end

  def index
    page = params[:page].to_i
    size = params[:size].to_i

    should_query = []
    must_query = []

    should_query << { match_phrase: { title: params[:query] } } if params[:query].present?
    should_query << { match_phrase: { director: params[:query] } } if params[:query].present?
    should_query << { match_phrase: { creator: params[:query] } } if params[:query].present?
    should_query << { nested: { path: 'cast_member_contents',
                            query: { nested: { path: 'cast_member_contents.cast_member',
                                                query: {
                                                  match_phrase: {
                                                    'cast_member_contents.cast_member.name': params[:query]
                                                  }
                                                }
                                              }
                                    }
                            }
              } if params[:query].present?

    must_query << { match_phrase: { type: params[:type] } } if params[:type].present?
    must_query << { bool: { must: { terms: { combined_genres: params[:genres].map { |genre| genre.downcase } } } } } if params[:genres].present?
    must_query << { nested: { path: 'content_streaming_sites',
                              query: { nested: { path: 'content_streaming_sites.streaming_site',
                                                  query: {
                                                    bool: {
                                                      must: {
                                                        terms: {
                                                          'content_streaming_sites.streaming_site.name': params[:platforms].map { |genre| genre.downcase }
                                                        }
                                                      }
                                                    }
                                                  }
                                              }
                                    }
                            }
                  } if params[:platforms].present?

    records = Content.search(
      size: size,
      from: page,
      query: {
        bool: {
          should: should_query,
          must: must_query,
          minimum_should_match: (should_query.blank? ? 0 : 1)
        }
      }
    )

    serialized_records = records.map do |record|
      { score: record['_score'], record: record['_source'].slice('id', 'image_url', 'title') }
    end

    render json: { records: serialized_records, total:  }, status: 200
  end
end
