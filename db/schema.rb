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

ActiveRecord::Schema[8.0].define(version: 2025_08_16_224741) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contributions", force: :cascade do |t|
    t.bigint "expense_id", null: false
    t.bigint "user_id", null: false
    t.decimal "percentage", precision: 5, scale: 2, null: false
    t.decimal "amount_due", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amount_due"], name: "index_contributions_on_amount_due"
    t.index ["expense_id", "user_id"], name: "index_contributions_on_expense_id_and_user_id", unique: true
    t.index ["expense_id"], name: "index_contributions_on_expense_id"
    t.index ["percentage"], name: "index_contributions_on_percentage"
    t.index ["user_id"], name: "index_contributions_on_user_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.string "description"
    t.decimal "amount"
    t.date "date"
    t.bigint "user_id", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "financial_group_id"
    t.index ["amount"], name: "index_expenses_on_amount"
    t.index ["category"], name: "index_expenses_on_category"
    t.index ["financial_group_id"], name: "index_expenses_on_financial_group_id"
    t.index ["user_id", "category"], name: "index_expenses_on_user_id_and_category"
    t.index ["user_id", "date"], name: "index_expenses_on_user_id_and_date"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "financial_groups", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "strategy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_financial_groups_on_name"
    t.index ["strategy_id"], name: "index_financial_groups_on_strategy_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "strategies", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_strategies_on_name", unique: true
  end

  create_table "user_financial_groups", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "financial_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["financial_group_id"], name: "index_user_financial_groups_on_financial_group_id"
    t.index ["user_id", "financial_group_id"], name: "index_user_financial_groups_unique", unique: true
    t.index ["user_id"], name: "index_user_financial_groups_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.decimal "income", precision: 10, scale: 2, default: "0.0"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["income"], name: "index_users_on_income"
    t.index ["name"], name: "index_users_on_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "contributions", "expenses"
  add_foreign_key "contributions", "users"
  add_foreign_key "expenses", "financial_groups"
  add_foreign_key "expenses", "users"
  add_foreign_key "financial_groups", "strategies"
  add_foreign_key "user_financial_groups", "financial_groups"
  add_foreign_key "user_financial_groups", "users"
end
