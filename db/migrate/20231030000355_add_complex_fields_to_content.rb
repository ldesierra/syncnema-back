class AddComplexFieldsToContent < ActiveRecord::Migration[7.0]
  def change
    rename_column :contents, :duration, :combined_runtime
    add_column :contents, :combined_release_date, :string
    add_column :contents, :combined_plot, :text
    add_column :contents, :combined_genres, :jsonb
    add_column :contents, :combined_budget, :integer
    add_column :contents, :combined_revenue, :integer
  end
end
