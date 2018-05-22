# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180424143207) do

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "egov_utils_addresses", force: :cascade do |t|
    t.integer "egov_identifier"
    t.string "street"
    t.string "house_number"
    t.string "orientation_number"
    t.string "city"
    t.string "city_part"
    t.string "postcode"
    t.string "district"
    t.string "region"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "egov_utils_groups", force: :cascade do |t|
    t.string "name"
    t.string "provider"
    t.string "roles"
    t.string "ldap_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_uid"
  end

  create_table "egov_utils_groups_users", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.index ["group_id"], name: "index_egov_utils_groups_users_on_group_id"
    t.index ["user_id"], name: "index_egov_utils_groups_users_on_user_id"
  end

  create_table "egov_utils_legal_people", force: :cascade do |t|
    t.integer "person_id"
    t.string "name"
    t.string "ico"
    t.integer "legal_form"
    t.index ["person_id"], name: "index_egov_utils_legal_people_on_person_id"
  end

  create_table "egov_utils_natural_people", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.date "birth_date"
    t.string "external_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "birth_place"
    t.integer "residence_id"
    t.integer "person_id"
    t.string "title"
    t.string "higher_title"
    t.index ["person_id"], name: "index_egov_utils_natural_people_on_person_id"
    t.index ["residence_id"], name: "index_egov_utils_natural_people_on_residence_id"
  end

  create_table "egov_utils_people", force: :cascade do |t|
    t.integer "person_type"
    t.string "joid"
    t.integer "residence_id"
    t.index ["residence_id"], name: "index_egov_utils_people_on_residence_id"
  end

  create_table "egov_utils_users", force: :cascade do |t|
    t.string "login"
    t.string "mail"
    t.string "password_digest"
    t.string "firstname"
    t.string "lastname"
    t.boolean "active", default: false
    t.string "roles"
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "confirmation_code"
    t.boolean "must_change_password"
    t.datetime "password_changed_at"
  end

end
