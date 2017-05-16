<<<<<<< HEAD
json.extract! ingredient, :id, :product_id, :recipe_id, :quantity, :created_at, :updated_at
=======
json.extract! ingredient, :id, :product_id, :item_id, :quantity, :created_at, :updated_at
>>>>>>> develop
json.url ingredient_url(ingredient, format: :json)
