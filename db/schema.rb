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

ActiveRecord::Schema[8.1].define(version: 2026_03_07_130518) do
  create_table "plans", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "BRL", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.integer "duration_count"
    t.string "duration_type"
    t.integer "interval_count", default: 1, null: false
    t.string "interval_type", default: "month", null: false
    t.string "name", null: false
    t.integer "price_cents", null: false
    t.boolean "renewable", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_plans_on_discarded_at"
  end

  create_table "profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document", null: false
    t.string "full_name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["document"], name: "index_profiles_on_document", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.date "canceled_at"
    t.date "closed_at"
    t.datetime "created_at", null: false
    t.date "joined_at", null: false
    t.date "next_due_date", null: false
    t.string "payment_method"
    t.integer "plan_id", null: false
    t.string "status", default: "pending_payment", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["closed_at"], name: "index_subscriptions_on_closed_at"
    t.index ["next_due_date"], name: "index_subscriptions_on_next_due_date"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["user_id", "plan_id", "status"], name: "index_subscriptions_on_user_id_and_plan_id_and_status"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "profiles", "users"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "users"
end
