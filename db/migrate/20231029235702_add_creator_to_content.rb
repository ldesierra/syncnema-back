class AddCreatorToContent < ActiveRecord::Migration[7.0]
  def change
    add_column :contents, :creator, :string
  end
end
