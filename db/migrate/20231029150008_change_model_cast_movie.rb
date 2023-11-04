class ChangeModelCastMovie < ActiveRecord::Migration[7.0]
  def change
    remove_reference :cast_members, :content
  end
end
