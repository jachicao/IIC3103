json.extract! product, :id, :sku, :storeHouseId, :cost, :name, :created_at, :updated_at
json.url product_url(product, format: :json)
