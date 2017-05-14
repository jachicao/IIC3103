json.extract! product_in_sale, :id, :producer_id, :product_id, :price, :average_time, :created_at, :updated_at
json.url product_in_sale_url(product_in_sale, format: :json)
