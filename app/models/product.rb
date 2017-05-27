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

  def get_purchase_lote(quantity)
    return lote * (quantity.to_f / lote.to_f).ceil
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
    me = Producer.all.find_by(me: true)
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
    if product_stock_available >= quantity

    else
      if ingredients.size == 0
        produce_time = 0
        me.product_in_sales.each do |product_in_sale|
          if product_in_sale.product.sku == sku
            produce_time = product_in_sale.average_time
            break
          end
        end
        purchase_items.push({ producer_id: me.producer_id, sku: sku, quantity: quantity, produce_time: produce_time })
      else
        ingredients.each do |ingredient|
          product_in_sale = ingredient.item.product_in_sales.order('average_time ASC').first
          produce_time = product_in_sale.average_time
          maximum_time_to_produce = [maximum_time_to_produce, produce_time].max
          purchase_items.push({ producer_id: product_in_sale.producer.producer_id, sku: ingredient.item.sku, quantity: ingredient.quantity, produce_time: produce_time })
        end
      end
    end
    return {
        :maximum_time => maximum_time_to_produce,
        :purchase_items => purchase_items,
    }
  end

  def self.purchase_stock(purchase_items)
    failed = false
    me = Producer.all.find_by(me: true)

    purchase_items.each do |item|
      if me.producer_id == item[:producer_id]
        buy_to_factory(item[:sku],item[:quantity])
      else
        if buy_to_producer(item[:sku], item[:quantity], item[:producer_id], item[:produce_time], 1)
        else
          failed = true
        end
      end
    end
    return !failed
  end

  def self.buy_to_producer(sku, quantity, producer_id, produce_time, unit_price)
    return PurchaseOrder.create_new_purchase_order(
        producer_id,
        sku,
        (Time.now + produce_time.to_f.hours).to_i * 1000,
        quantity.to_i,
        unit_price, #TODO: Completar esto
        'contra_despacho' #TODO: Completar esto
    )
  end

  def self.buy_to_factory(sku, quantity)
    product = Product.all.find_by(sku: sku)
    lote = product.get_purchase_lote(quantity)
    unit_price = product.unit_cost
    BuyFactoryProductsJob.perform_later(sku, lote, unit_price)
  end

end