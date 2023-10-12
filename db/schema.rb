ActiveRecord::Schema[7.0].define(version: 2023_10_12_223502) do
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
