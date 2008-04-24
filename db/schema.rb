# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "fields", :force => true do |t|
    t.string  "fkey",        :default => "", :null => false
    t.string  "vclass",      :default => "", :null => false
    t.string  "svalue"
    t.text    "yvalue"
    t.integer "workitem_id",                 :null => false
  end

  add_index "fields", ["workitem_id", "fkey"], :name => "index_fields_on_workitem_id_and_fkey", :unique => true
  add_index "fields", ["fkey"], :name => "index_fields_on_fkey"
  add_index "fields", ["vclass"], :name => "index_fields_on_vclass"
  add_index "fields", ["svalue"], :name => "index_fields_on_svalue"

  create_table "groups", :force => true do |t|
    t.string "name",     :default => "", :null => false
    t.string "username", :default => "", :null => false
  end

  create_table "launch_permissions", :force => true do |t|
    t.string "groupname", :default => "", :null => false
    t.string "url",       :default => "", :null => false
  end

  create_table "store_permissions", :force => true do |t|
    t.string "storename",  :default => "", :null => false
    t.string "groupname",  :default => "", :null => false
    t.string "permission", :default => "", :null => false
  end

  create_table "users", :force => true do |t|
    t.string  "name",            :default => "",    :null => false
    t.string  "hashed_password", :default => "",    :null => false
    t.string  "salt",            :default => "",    :null => false
    t.boolean "admin",           :default => false, :null => false
  end

  create_table "wi_stores", :force => true do |t|
    t.string "name"
    t.string "regex"
  end

  create_table "workitems", :force => true do |t|
    t.string   "fei"
    t.string   "wfid"
    t.string   "wf_name"
    t.string   "wf_revision"
    t.string   "participant_name"
    t.string   "store_name"
    t.datetime "dispatch_time"
    t.datetime "last_modified"
    t.text     "yattributes"
  end

  add_index "workitems", ["fei"], :name => "index_workitems_on_fei", :unique => true
  add_index "workitems", ["wfid"], :name => "index_workitems_on_wfid"
  add_index "workitems", ["wf_name"], :name => "index_workitems_on_wf_name"
  add_index "workitems", ["wf_revision"], :name => "index_workitems_on_wf_revision"
  add_index "workitems", ["participant_name"], :name => "index_workitems_on_participant_name"
  add_index "workitems", ["store_name"], :name => "index_workitems_on_store_name"

end
