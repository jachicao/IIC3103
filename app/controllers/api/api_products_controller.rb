class Api::ApiProductsController < Api::ApiController

  # GET /products
  # GET /products.json
  def index
    return render json: Product.get_api_result
  end


  def get_stock
    result = []
    me = Producer.get_me
    me.product_in_sales.each do |product_in_sale|
      product = product_in_sale.product
      result.push({ sku: product.sku, precio: product_in_sale.price, stock: product.stock_available })
    end
    return render json: result
  end
end
