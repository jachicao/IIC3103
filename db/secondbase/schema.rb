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

ActiveRecord::Schema.define(version: 20170701225752) do

  create_table "azure_bank_transactions", force: :cascade do |t|
    t.string  "_id"
    t.string  "from"
    t.string  "to"
    t.integer "amount"
    t.index ["_id"], name: "index_azure_bank_transactions_on__id"
  end

  create_table "azure_dates", force: :cascade do |t|
    t.datetime "date"
    t.string   "description"
    t.integer  "minute"
    t.integer  "hour"
    t.integer  "day"
    t.string   "day_of_the_week"
    t.integer  "day_of_the_year"
    t.integer  "week_of_the_year"
    t.string   "month"
    t.integer  "year"
  end

  create_table "azure_invoice_over_times", force: :cascade do |t|
    t.integer "azure_date_id"
    t.integer "azure_invoice_id"
    t.string  "status"
    t.index ["azure_date_id"], name: "index_azure_invoice_over_times_on_azure_date_id"
    t.index ["azure_invoice_id"], name: "index_azure_invoice_over_times_on_azure_invoice_id"
  end

  create_table "azure_invoices", force: :cascade do |t|
    t.integer  "azure_purchase_order_id"
    t.integer  "azure_bank_transaction_id"
    t.string   "_id"
    t.string   "po_id"
    t.string   "client"
    t.string   "supplier"
    t.integer  "amount"
    t.string   "bank_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["_id"], name: "index_azure_invoices_on__id"
    t.index ["azure_bank_transaction_id"], name: "index_azure_invoices_on_azure_bank_transaction_id"
    t.index ["azure_purchase_order_id"], name: "index_azure_invoices_on_azure_purchase_order_id"
  end

  create_table "azure_product_stock_over_times", force: :cascade do |t|
    t.integer "azure_date_id"
    t.integer "azure_product_id"
    t.integer "stock"
    t.integer "stock_available"
    t.index ["azure_date_id"], name: "index_azure_product_stock_over_times_on_azure_date_id"
    t.index ["azure_product_id"], name: "index_azure_product_stock_over_times_on_azure_product_id"
  end

  create_table "azure_products", force: :cascade do |t|
    t.string  "sku"
    t.string  "name"
    t.string  "product_type"
    t.string  "unit"
    t.integer "unit_cost"
    t.index ["sku"], name: "index_azure_products_on_sku"
  end

  create_table "azure_purchase_order_over_times", force: :cascade do |t|
    t.integer "azure_date_id"
    t.integer "azure_purchase_order_id"
    t.string  "status"
    t.integer "quantity_dispatched"
    t.index ["azure_date_id"], name: "index_azure_purchase_order_over_times_on_azure_date_id"
    t.index ["azure_purchase_order_id"], name: "index_azure_purchase_order_over_times_on_azure_purchase_order_id"
  end

  create_table "azure_purchase_orders", force: :cascade do |t|
    t.integer  "azure_product_id"
    t.string   "_id"
    t.string   "payment_method"
    t.string   "store_reception_id"
    t.integer  "quantity"
    t.string   "client"
    t.string   "supplier"
    t.integer  "unit_price"
    t.datetime "delivery_date"
    t.string   "channel"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["_id"], name: "index_azure_purchase_orders_on__id"
    t.index ["azure_product_id"], name: "index_azure_purchase_orders_on_azure_product_id"
  end

  create_table "azure_store_house_over_times", force: :cascade do |t|
    t.integer "azure_date_id"
    t.integer "azure_store_house_id"
    t.integer "used_space"
    t.integer "available_space"
    t.index ["azure_date_id"], name: "index_azure_store_house_over_times_on_azure_date_id"
    t.index ["azure_store_house_id"], name: "index_azure_store_house_over_times_on_azure_store_house_id"
  end

  create_table "azure_store_houses", force: :cascade do |t|
    t.string  "_id"
    t.integer "total_space"
    t.string  "store_type"
    t.index ["_id"], name: "index_azure_store_houses_on__id"
  end

  add_foreign_key "azure_invoice_over_times", "azure_dates"
  add_foreign_key "azure_invoice_over_times", "azure_invoices"
  add_foreign_key "azure_invoices", "azure_bank_transactions"
  add_foreign_key "azure_invoices", "azure_purchase_orders"
  add_foreign_key "azure_product_stock_over_times", "azure_dates"
  add_foreign_key "azure_product_stock_over_times", "azure_products"
  add_foreign_key "azure_purchase_order_over_times", "azure_dates"
  add_foreign_key "azure_purchase_order_over_times", "azure_purchase_orders"
  add_foreign_key "azure_purchase_orders", "azure_products"
  add_foreign_key "azure_store_house_over_times", "azure_dates"
  add_foreign_key "azure_store_house_over_times", "azure_store_houses"
end
