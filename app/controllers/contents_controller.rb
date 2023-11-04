class ContentsController < ApplicationController
  def show
    content = Content.find_by(id: params[:id])

    return render json: { error: 'Not found' }, status: 404 if content.blank?

    render json: content, status: 200
  end

  def index
    query = []
    query << { term: { id: params[:id] } } if params[:id].present?
    query << { match_phrase: { type: "#{params[:type]}" } } if params[:type].present?
    query << { match_phrase: { director: "#{params[:director]}" } } if params[:director].present?
    query << { match_phrase: { title: "#{params[:title]}" } } if params[:title].present?
    query << { match_phrase: { combined_genres: "#{params[:genres]}" } } if params[:genres].present?
    query << { nested: { path: "cast_member_contents",
                         query: { nested: { path: "cast_member_contents.cast_member",
                                            query: {
                                              match_phrase: {
                                                "cast_member_contents.cast_member.name": params[:actor]
                                              }
                                            }
                                          }
                                }
                        }
              } if params[:actor].present?
    query << { nested: { path: "content_streaming_sites",
                query: { nested: { path: "content_streaming_sites.streaming_site",
                                   query: {
                                     match_phrase: {
                                       "content_streaming_sites.streaming_site.name": params[:streaming]
                                     }
                                   }
                                 }
                       }
               }
     } if params[:streaming].present?

    records = Content.search(
      query: {
        bool: {
          must: query
            #{ nested: { path: "cast_member_contents", query: { match_phrase: { "cast_member_contents.cast_member.name": "John" } } } }
          #]
        }
      }
    )

    render json: records, status: 200
  end
end
