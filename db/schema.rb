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

ActiveRecord::Schema.define(version: 20140615230522) do

  create_table "adverts", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "category_id"
    t.text     "fieldvalues"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price"
    t.string   "price_type"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.text     "fields"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_hierarchies", id: false, force: true do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "category_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "category_anc_desc_udx", unique: true
  add_index "category_hierarchies", ["descendant_id"], name: "category_desc_idx"

  create_table "uploads", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "advert_id"
    t.text     "description"
  end

end
