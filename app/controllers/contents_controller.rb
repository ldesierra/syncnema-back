class ContentsController < ApplicationController
  def show
    content = Content.find_by(id: params[:id])
    user = User.find_by(external_id: params[:user_id])

    return render json: { error: 'Not found' }, status: 404 if content.blank?

    serialized_content = content.slice(
      :trailer_url, :combined_plot, :image_url, :combined_release_date,
      :content_rating, :combined_runtime, :director, :creator, :title, :combined_genres,
      :rating, :combined_budget, :combined_revenue, :id
    )

    favourite = Favourite.find_by(
      user_id: user&.id, content_id: content.id
    ).present?
    serialized_content.merge!(favourite: favourite)

    rating = Rating.find_by(
      user_id: user&.id, content_id: content.id
    )&.score
    serialized_content = serialized_content.merge!(user_rating: rating)

    cast = CastMemberContent.where(content_id: content.id).map(&:cast_member) .map do |member|
      {
        name: member.name,
        awards: member.awards,
        image: member.image
      }
    end

    sites = ContentStreamingSite.where(content_id: content.id).map(&:streaming_site)
    sites = sites.group_by(&:name).values.map(&:first)

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
    genres = if params[:genres].blank?
               nil
             elsif params[:genres].class.name == 'Array'
               params[:genres]
             else
               JSON.parse(params[:genres])
             end

    platforms = if params[:platforms].blank?
              nil
            elsif params[:platforms].class.name == 'Array'
              params[:platforms]
            else
              JSON.parse(params[:platforms])
            end

    page = params[:page].to_i
    size = params[:size].presence&.to_i || 20

    should_query = []
    must_query = []

    should_query << { wildcard: { title: "*#{params[:query].underscore}*" } } if params[:query].present?
    should_query << { wildcard: { director: "*#{params[:query].underscore}*" } } if params[:query].present?
    should_query << { wildcard: { creator: "*#{params[:query].underscore}*" } } if params[:query].present?
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
    must_query << { query_string: { query: genres.join(' OR'),
                                    default_field: 'combined_genres' }
                  } if genres.present?
    must_query << { nested: { path: 'content_streaming_sites',
                              query: { nested: { path: 'content_streaming_sites.streaming_site',
                                                  query: {
                                                    query_string: {
                                                      query: platforms.join(' OR '),
                                                      default_field: "content_streaming_sites.streaming_site.name"
                                                    }
                                                  }
                                              }
                                    }
                            }
                  } if platforms.present?

    records = Content.search(
      size: size,
      from: page * size,
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

    render json: {
      records: serialized_records,
      total: records.response['hits']['total']['value'],
      page: page
    }, status: 200
  end

  def provenance
    xml_content = File.read(Rails.root.join('app', 'views', 'provenance.xml'))

    render xml: xml_content, status: 200
  end
end
