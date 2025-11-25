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

ActiveRecord::Schema[8.1].define(version: 2025_10_27_235457) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "atividades", force: :cascade do |t|
    t.boolean "ativo"
    t.datetime "created_at", null: false
    t.text "descricao"
    t.json "dias_semana", default: []
    t.integer "frequencia_semanal"
    t.string "nome"
    t.bigint "objetivo_id", null: false
    t.datetime "updated_at", null: false
    t.index ["objetivo_id"], name: "index_atividades_on_objetivo_id"
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
    t.bigint "atividade_id", null: false
    t.boolean "concluido"
    t.datetime "created_at", null: false
    t.date "data"
    t.text "observacao"
    t.datetime "updated_at", null: false
    t.index ["atividade_id"], name: "index_registros_on_atividade_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "atividades", "objetivos"
  add_foreign_key "objetivos", "users"
  add_foreign_key "registros", "atividades"
end
