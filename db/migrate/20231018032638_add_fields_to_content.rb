class AddFieldsToContent < ActiveRecord::Migration[7.0]
  def change
    add_column :contents, :adult, :boolean
    add_column :contents, :overview, :text
    add_column :contents, :release, :date
    add_column :contents, :duration, :date
    add_column :contents, :image_url, :string
    add_column :contents, :content_rating, :string
    add_column :contents, :trailer_url, :string
  end
end
