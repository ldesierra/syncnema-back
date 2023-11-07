class ChangeToBigint < ActiveRecord::Migration[7.0]
  def change
    change_column :contents, :budget, :bigint
    change_column :contents, :production_budget, :bigint
    change_column :contents, :combined_budget, :bigint
    change_column :contents, :revenue, :bigint
    change_column :contents, :lifetime_gross, :bigint
    change_column :contents, :combined_revenue, :bigint
  end
end
