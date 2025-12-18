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

ActiveRecord::Schema[8.1].define(version: 2025_12_18_232603) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "habitos", force: :cascade do |t|
    t.boolean "ativo"
    t.datetime "created_at", null: false
    t.text "descricao"
    t.json "dias_semana", default: []
    t.integer "frequencia_semanal"
    t.string "nome"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_habitos_on_user_id"
  end

  create_table "habitos_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "habito_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["habito_id", "tag_id"], name: "index_habitos_tags_on_habito_id_and_tag_id", unique: true
    t.index ["habito_id"], name: "index_habitos_tags_on_habito_id"
    t.index ["tag_id"], name: "index_habitos_tags_on_tag_id"
  end

  create_table "objetivos", force: :cascade do |t|
    t.boolean "ativo"
    t.datetime "created_at", null: false
    t.text "descricao"
    t.string "nome"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_objetivos_on_user_id"
  end

  create_table "registros", force: :cascade do |t|
    t.boolean "concluido"
    t.datetime "created_at", null: false
    t.date "data"
    t.bigint "habito_id", null: false
    t.text "observacao"
    t.datetime "updated_at", null: false
    t.index ["habito_id"], name: "index_registros_on_habito_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "cor", default: "#6c757d"
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "nome"], name: "index_tags_on_user_id_and_nome", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "premium", default: false, null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.datetime "trial_ends_at"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id"
    t.index ["stripe_subscription_id"], name: "index_users_on_stripe_subscription_id"
  end

  add_foreign_key "habitos", "users"
  add_foreign_key "habitos_tags", "habitos"
  add_foreign_key "habitos_tags", "tags"
  add_foreign_key "objetivos", "users"
  add_foreign_key "registros", "habitos"
  add_foreign_key "tags", "users"
end
