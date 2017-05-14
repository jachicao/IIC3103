json.extract! product, :id, :sku, :name, :product_type, :unit, :unit_cost, :lote, :created_at, :updated_at
json.url product_url(product, format: :json)
