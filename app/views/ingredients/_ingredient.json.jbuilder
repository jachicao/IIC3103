json.extract! ingredient, :id, :product_id, :recipe_id, :quantity, :created_at, :updated_at
json.url ingredient_url(ingredient, format: :json)
