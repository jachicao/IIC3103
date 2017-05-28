class Product < ApplicationRecord
  has_many :ingredients
  has_many :product_in_sales

  def get_stock
    stock = 0
    store_houses = StoreHouse.all_stock

    if store_houses == nil
      return stock
    end

    store_houses.each do |store_house|
      store_house[:inventario].each do |p|
        if sku == p[:sku]
          stock += p[:total]
        end
      end
    end
    return stock
  end

  def stock_available(stock)
    counter = 0
    stock.each do |store_house|
      store_house[:inventario].each do |p|
        if sku == p[:sku]
          counter += p[:total]
        end
      end
    end
    return counter
  end

  def analyze_stock(quantity)
    me = Producer.get_me
    all_stock = StoreHouse.all_stock
    if all_stock == nil
      return nil
    end
    stock = []
    all_stock.each do |store_house|
      if !store_house[:despacho]
        stock.push(store_house)
      end
    end
    maximum_time_to_produce = 0.0
    purchase_items = []
    product_stock_available = stock_available(stock)
    unit_lote = (quantity.to_f / lote.to_f).ceil
    if false#product_stock_available >= quantity #TODO

    else
      if ingredients.size == 0
        produce_time = 0
        me.product_in_sales.each do |product_in_sale|
          if product_in_sale.product.sku == sku
            produce_time = product_in_sale.average_time
            break
          end
        end
        purchase_items.push({ producer_id: me.producer_id, sku: sku, quantity: unit_lote, lote: lote, produce_time: produce_time })
      else
        ingredients.each do |ingredient|
          puts ingredient.item.sku
          puts ingredient.item.product_in_sales.size
          product_in_sale = ingredient.item.product_in_sales.order('average_time ASC').first
          produce_time = product_in_sale.average_time
          maximum_time_to_produce = [maximum_time_to_produce, produce_time].max
          purchase_items.push({ producer_id: product_in_sale.producer.producer_id, sku: ingredient.item.sku, quantity: unit_lote, lote: ingredient.quantity, produce_time: produce_time })
        end
      end
    end
    return {
        :maximum_time => maximum_time_to_produce,
        :purchase_items => purchase_items,
        :quantity => unit_lote,
        :lote => lote,
    }
  end

  def purchase_stock(lote, quantity, purchase_items)
    pending_product = PendingProduct.create(product: self, quantity: quantity, lote: lote)
    purchase_items.each do |item|
      product_item = Product.all.find_by(sku: item[:sku])
      producer = Producer.all.find_by(producer_id: item[:producer_id])
      pending_product.purchased_products.create(product: product_item, producer: producer, quantity: item[:quantity], lote: item[:lote], produce_time: item[:produce_time])
    end
  end

end