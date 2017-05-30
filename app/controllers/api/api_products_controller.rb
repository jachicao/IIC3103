class Api::ApiProductsController < Api::ApiController

  # GET /products
  # GET /products.json
  def index
    res = []
    me = Producer.get_me
    me.product_in_sales.each do |product_in_sale|
      res.push({ sku: product_in_sale.product.sku, name: product_in_sale.product.name, price: product_in_sale.price })
    end
    render json: {
      :product => res
    }
  end


  def get_stock
    result = []
    all_stock = StoreHouse.all_stock
    if all_stock == nil
      return render json: result
    end
    me = Producer.get_me
    products = []
    me.product_in_sales.each do |product_in_sale|
      product = product_in_sale.product
      products[product.sku.to_i] = { sku: product.sku, precio: product_in_sale.price, stock: 0 }
    end
    all_stock.each do |store_house|
      store_house[:inventario].each do |p|
        product = products[p[:sku].to_i]
        if product != nil
          product[:stock] += p[:total]
        end
      end
    end

    products.each do |product|
      if product != nil
        result.push(product)
      end
    end

    return render json: result
  end
end
