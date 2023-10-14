class CreateContents < ActiveRecord::Migration[7.0]
  def change
    create_table :contents do |t|
      t.string :type
      t.string :title
      t.string :imdb_id
      t.string :tmdb_id

      t.timestamps
    end
  end
end
