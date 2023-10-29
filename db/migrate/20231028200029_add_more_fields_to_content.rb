class AddMoreFieldsToContent < ActiveRecord::Migration[7.0]
  def change
    remove_column :contents, :release, :date
    remove_column :contents, :duration, :date
    add_column :contents, :duration, :integer
    add_column :contents, :plot, :text
    add_column :contents, :revenue, :integer
    add_column :contents, :lifetime_gross, :integer
    add_column :contents, :tmdb_genres, :text
    add_column :contents, :imdb_genres, :text
    add_column :contents, :tmdb_runtime, :integer
    add_column :contents, :imdb_runtime, :integer
    add_column :contents, :production_budget, :integer
    add_column :contents, :budget, :integer
    add_column :contents, :review_name, :string
    add_column :contents, :review_body, :string
    add_column :contents, :rating, :integer
    add_column :contents, :metacritic, :integer
    add_column :contents, :episodes, :integer
    add_column :contents, :trivia, :text
    add_column :contents, :quotes, :text
    add_column :contents, :release_date_imdb, :string
    add_column :contents, :release_date_tmdb, :string
    add_column :contents, :director, :string
  end
end
