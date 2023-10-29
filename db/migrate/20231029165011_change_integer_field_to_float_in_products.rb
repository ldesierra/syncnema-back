class ChangeIntegerFieldToFloatInProducts < ActiveRecord::Migration[7.0]
  def change
    change_column :contents, :rating, :float
  end
end
