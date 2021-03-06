# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_02_123522) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "food_logs", force: :cascade do |t|
    t.integer "calories"
    t.integer "protein"
    t.integer "carbohydrates"
    t.integer "fat"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "request_id", null: false
    t.bigint "user_id", null: false
    t.index ["request_id"], name: "index_food_logs_on_request_id"
    t.index ["user_id"], name: "index_food_logs_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.json "parameters"
    t.string "response_body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.integer "calorie_goal"
    t.integer "protein_goal"
    t.integer "carbohydrate_goal"
    t.integer "fat_goal"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "food_logs", "requests"
  add_foreign_key "food_logs", "users"
end
