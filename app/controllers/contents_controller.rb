class ContentsController < ApplicationController
  def show
    content = Content.find_by(id: params[:id])

    return render json: { error: 'Not found' }, status: 404 if content.blank?

    render json: content, status: 200
  end

  def index
    query = []
    query << { match_phrase: { director: "#{params[:director]}" } } if params[:director].present?
    query << { match_phrase: { title: "#{params[:title]}" } } if params[:title].present?
    query << { match_phrase: { combined_genres: "#{params[:genres]}" } } if params[:genres].present?

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
