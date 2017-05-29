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

ActiveRecord::Schema.define(version: 20170529014350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "factory_orders", id: :bigserial, force: :cascade do |t|
    t.string   "fo_id"
    t.string   "sku"
    t.datetime "available"
    t.integer  "quantity"
    t.index ["fo_id"], name: "index_factory_orders_on_fo_id", using: :btree
  end

  create_table "ingredients", id: :bigserial, force: :cascade do |t|
    t.bigint   "product_id"
    t.bigint   "item_id"
    t.integer  "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_ingredients_on_product_id", using: :btree
  end

  create_table "invoices", force: :cascade do |t|
    t.string   "_id"
    t.string   "supplier"
    t.string   "client"
    t.integer  "total_amount"
    t.string   "po_id"
    t.datetime "payment_date"
    t.boolean  "is_bill",      default: false
  end

  create_table "pending_products", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_pending_products_on_product_id", using: :btree
  end

  create_table "producers", id: :bigserial, force: :cascade do |t|
    t.string   "producer_id"
    t.integer  "group_number"
    t.string   "account"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "me",           default: false
    t.index ["producer_id"], name: "index_producers_on_producer_id", using: :btree
  end

  create_table "product_in_sales", id: :bigserial, force: :cascade do |t|
    t.bigint   "producer_id"
    t.bigint   "product_id"
    t.integer  "price"
    t.decimal  "average_time"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.boolean  "mine"
    t.index ["producer_id"], name: "index_product_in_sales_on_producer_id", using: :btree
    t.index ["product_id"], name: "index_product_in_sales_on_product_id", using: :btree
  end

  create_table "products", id: :bigserial, force: :cascade do |t|
    t.string   "sku"
    t.string   "name"
    t.string   "product_type"
    t.string   "unit"
    t.integer  "unit_cost"
    t.integer  "lote"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "purchase_orders", id: :bigserial, force: :cascade do |t|
    t.string   "po_id"
    t.string   "payment_method"
    t.string   "store_reception_id"
    t.string   "status"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.boolean  "own"
    t.boolean  "dispatched"
    t.index ["po_id"], name: "index_purchase_orders_on_po_id", using: :btree
  end

  create_table "purchased_products", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "producer_id"
    t.integer  "pending_product_id"
    t.string   "po_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["pending_product_id"], name: "index_purchased_products_on_pending_product_id", using: :btree
    t.index ["producer_id"], name: "index_purchased_products_on_producer_id", using: :btree
    t.index ["product_id"], name: "index_purchased_products_on_product_id", using: :btree
  end

  add_foreign_key "ingredients", "products"
  add_foreign_key "pending_products", "products"
  add_foreign_key "product_in_sales", "producers"
  add_foreign_key "product_in_sales", "products"
  add_foreign_key "purchased_products", "pending_products"
  add_foreign_key "purchased_products", "producers"
  add_foreign_key "purchased_products", "products"
end
