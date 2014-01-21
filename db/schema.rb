# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140117101133) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contacts", force: true do |t|
    t.boolean  "active",                   default: true
    t.string   "civility",      limit: 4,                 null: false
    t.string   "first_name",                              null: false
    t.string   "last_name",                               null: false
    t.date     "date_of_birth",                           null: false
    t.string   "address"
    t.string   "zip_code",      limit: 5
    t.string   "city"
    t.string   "phone_number",  limit: 10
    t.string   "mobile_number", limit: 10
    t.string   "email",                                   null: false
    t.string   "website"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo"
    t.integer  "country_id"
  end

  add_index "contacts", ["country_id"], name: "index_contacts_on_country_id", using: :btree
  add_index "contacts", ["email"], name: "index_contacts_on_email", unique: true, using: :btree

  create_table "contacts_jobs", id: false, force: true do |t|
    t.integer "job_id",     null: false
    t.integer "contact_id", null: false
  end

  create_table "countries", force: true do |t|
    t.string "code", limit: 2, null: false
    t.string "name",           null: false
  end

  add_index "countries", ["code"], name: "index_countries_on_code", unique: true, using: :btree
  add_index "countries", ["name"], name: "index_countries_on_name", unique: true, using: :btree

  create_table "jobs", force: true do |t|
    t.string   "name",                      null: false
    t.boolean  "active",     default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs", ["name"], name: "index_jobs_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                           null: false
    t.string   "password_digest"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",                      null: false
    t.string   "last_name",                       null: false
    t.boolean  "active",          default: true
    t.boolean  "admin",           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
