# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100513081520) do

  create_table "backup", :force => true do |t|
    t.string   "storage"
    t.string   "trigger"
    t.string   "adapter"
    t.string   "filename"
    t.string   "path"
    t.string   "bucket"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "booth_structures", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "structure_id"
    t.integer  "inventory_capacity"
    t.integer  "item_price"
  end

  create_table "creatures", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "creature_type"
    t.string   "additional_info"
    t.integer  "x"
    t.integer  "y"
    t.integer  "z"
  end

  create_table "dwellings", :force => true do |t|
    t.string   "name"
    t.string   "symbol_name"
    t.string   "swf_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dwelling_type"
    t.integer  "capacity"
    t.integer  "unlocks_at"
  end

  create_table "layerables", :force => true do |t|
    t.string   "name"
    t.string   "swf_url"
    t.string   "symbol_name"
    t.string   "layer_name"
    t.boolean  "is_default"
    t.boolean  "editable_color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_store_owned"
  end

  create_table "levels", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rank"
    t.integer  "xp_diff"
    t.text     "items_unlocked"
    t.integer  "dwelling_expansion_x"
    t.integer  "dwelling_expansion_y"
    t.integer  "dwelling_expansion_z"
  end

  create_table "owned_dwellings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "dwelling_id"
    t.string   "current_city"
    t.integer  "fancount"
    t.datetime "fancount_updated_at"
    t.string   "last_state"
    t.datetime "state_updated_at"
  end

  create_table "owned_layerables", :force => true do |t|
    t.boolean  "in_use"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "layerable_id"
    t.integer  "r"
    t.integer  "g"
    t.integer  "b"
    t.integer  "creature_id"
  end

  create_table "owned_structures", :force => true do |t|
    t.float    "x"
    t.float    "y"
    t.float    "z"
    t.boolean  "in_use"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "structure_id"
    t.integer  "owned_dwelling_id"
    t.integer  "inventory_count"
    t.datetime "inventory_updated_at"
  end

  create_table "owned_thingers", :force => true do |t|
    t.boolean  "in_use"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "thinger_id"
    t.float    "x"
    t.float    "y"
    t.float    "z"
  end

  create_table "owned_usables", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "usable_id"
  end

  create_table "promoters", :force => true do |t|
    t.string   "promoter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "x"
    t.integer  "y"
    t.integer  "z"
    t.integer  "user_id"
  end

  create_table "store_owned_thingers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "store_id"
    t.integer  "price"
    t.integer  "premium_price"
    t.string   "thinger_type"
    t.integer  "thinger_id"
  end

  create_table "stores", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "structures", :force => true do |t|
    t.string   "name"
    t.string   "swf_url"
    t.string   "symbol_name"
    t.string   "structure_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "width"
    t.float    "height"
    t.float    "depth"
    t.integer  "collection_time"
    t.integer  "capacity"
  end

  create_table "thingers", :force => true do |t|
    t.string   "name"
    t.string   "thinger_type"
    t.string   "swf_url"
    t.string   "symbol_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_store_owned"
  end

  create_table "usables", :force => true do |t|
    t.string   "name"
    t.string   "swf_url"
    t.string   "symbol_name"
    t.string   "usable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "snid"
    t.integer  "xp"
    t.integer  "credits"
    t.integer  "premium_credits"
    t.datetime "last_showtime"
    t.integer  "level_id"
  end

end
