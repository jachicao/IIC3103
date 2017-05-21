class Api::ApiProductsController < Api::ApiController

  # GET /products
  # GET /products.json
  def index
    res = []
    me = Producer.all.find_by(me: true)
    me.product_in_sales.each do |product_in_sale|
      res.push({ sku: product_in_sale.product.sku, name: product_in_sale.product.name, price: product_in_sale.price })
    end
    render json: {
      :product => res
    }
  end
end
