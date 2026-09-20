# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_20_040004) do
  create_schema "extensions"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "public.channels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "name"], name: "index_channels_on_project_id_and_name", unique: true
  end

# Could not dump table "events" because of following ArgumentError
#   wrong number of arguments (given 2, expected 1)


  create_table "public.insights", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "icon"
    t.string "project_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["project_id", "title"], name: "index_insights_on_project_id_and_title", unique: true
  end

  create_table "public.projects", id: { type: :string, limit: 12 }, force: :cascade do |t|
    t.string "api_key", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key"], name: "index_projects_on_api_key", unique: true
  end

  add_foreign_key "public.channels", "public.projects"
  add_foreign_key "public.events", "public.projects"
  add_foreign_key "public.insights", "public.projects"

end
