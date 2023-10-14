class AddUsersExternalIds < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :external_id, :string, null: false
  end
end
