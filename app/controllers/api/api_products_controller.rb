class Api::ApiProductsController < Api::ApiController

  # GET /products
  # GET /products.json
  def index
    res = [];
    ProductInSale.all.each do |v|
      if v.producer.group_number == 1
        res.push({ sku: v.product.sku, name: v.product.name, price: v.price })
      end
    end
    render json: {
      :product => res
    }
  end
end
