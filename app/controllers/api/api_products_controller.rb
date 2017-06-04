class Api::ApiProductsController < Api::ApiController

  # GET /products
  # GET /products.json
  def index

    result = []
    me = Producer.get_me
    me.product_in_sales.each do |product_in_sale|
      product = product_in_sale.product
      result.push({ sku: product.sku, name: product.name, price: product_in_sale.price, stock: product.get_stock_available })
    end

    return render json: result
  end


  def get_stock
    result = []
    me = Producer.get_me
    me.product_in_sales.each do |product_in_sale|
      product = product_in_sale.product
      result.push({ sku: product.sku, precio: product_in_sale.price, stock: product.get_stock_available })
    end
    return render json: result
  end
end
