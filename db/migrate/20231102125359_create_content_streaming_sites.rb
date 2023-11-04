class CreateContentStreamingSites < ActiveRecord::Migration[7.0]
  def change
    create_table :content_streaming_sites do |t|
      t.references :content
      t.references :streaming_site

      t.timestamps
    end

    remove_reference :streaming_sites, :content
  end
end
