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

ActiveRecord::Schema.define(version: 20170426021302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "balances", force: :cascade do |t|
    t.string   "acount"
    t.decimal  "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bills", force: :cascade do |t|
    t.string   "supplier"
    t.string   "client"
    t.integer  "grossValue"
    t.integer  "iva"
    t.integer  "totalValue"
    t.string   "paymentStatus"
    t.string   "pushaseOrderId"
    t.datetime "paymentDeadline"
    t.string   "rejectionCause"
    t.string   "CancellationCause"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "sku"
    t.string   "storeHouseId"
    t.decimal  "cost"
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.string   "orderId"
    t.string   "channel"
    t.string   "supplier"
    t.string   "client"
    t.string   "Sku"
    t.integer  "quantity"
    t.integer  "dispatchedQuantity"
    t.integer  "unitPrice"
    t.datetime "deadline"
    t.string   "state"
    t.string   "rejectionCause"
    t.string   "CancellationCause"
    t.string   "notes"
    t.string   "billId"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "store_houses", force: :cascade do |t|
    t.integer  "usedSpace"
    t.integer  "totalSpace"
    t.boolean  "reception"
    t.boolean  "dispatch"
    t.boolean  "external"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string   "originAcount"
    t.string   "destinationAcount"
    t.decimal  "amount"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

end
