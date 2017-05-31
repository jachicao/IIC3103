class Api::ApiProductsController < Api::ApiController

  # GET /products
  # GET /products.json
  def index
    me = Producer.get_me
    products = []
    me.product_in_sales.each do |product_in_sale|
      product = product_in_sale.product
      products[product.sku.to_i] = { sku: product.sku, name: product.name, price: product_in_sale.price, stock: 0 }
    end
    all_stock = StoreHouse.all_stock
    if all_stock != nil
      all_stock.each do |store_house|
        store_house[:inventario].each do |p|
          product = products[p[:sku].to_i]
          if product != nil
            product[:stock] += p[:total]
          end
        end
      end
    end

    result = []
    products.each do |product|
      if product != nil
        result.push(product)
      end
    end

    return render json: result
  end


  def get_stock
    me = Producer.get_me
    products = []
    me.product_in_sales.each do |product_in_sale|
      product = product_in_sale.product
      products[product.sku.to_i] = { sku: product.sku, precio: product_in_sale.price, stock: 0 }
    end
    all_stock = StoreHouse.all_stock
    if all_stock != nil
      all_stock.each do |store_house|
        store_house[:inventario].each do |p|
          product = products[p[:sku].to_i]
          if product != nil
            product[:stock] += p[:total]
          end
        end
      end
    end

    result = []
    products.each do |product|
      if product != nil
        result.push(product)
      end
    end

    return render json: result
  end
end
