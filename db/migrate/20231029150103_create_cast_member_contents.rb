class CreateCastMemberContents < ActiveRecord::Migration[7.0]
  def change
    create_table :cast_member_contents do |t|
      t.references :content
      t.references :cast_member

      t.timestamps
    end
  end
end
