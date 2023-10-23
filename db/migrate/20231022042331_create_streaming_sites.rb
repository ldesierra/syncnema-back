class CreateStreamingSites < ActiveRecord::Migration[7.0]
  def change
    create_table :streaming_sites do |t|
      t.string :image_url
      t.string :name
      t.string :kind
      t.references :content, null: false

      t.timestamps
    end
  end
end
