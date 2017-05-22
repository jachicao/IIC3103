class FactoryOrder < ApplicationRecord

  def self.get_lote(lote, cantidad)
    return (cantidad.to_f / lote.to_f).ceil
  end

  def self.stock_available(stock, item)
    counter = 0
    stock.each do |store_house|
      store_house[:inventario].each do |p|
        if item.sku == p[:sku]
          counter += p[:total]
        end
      end
    end
    return counter
  end

  def self.analyze_stock(product, quantity)
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
    product_stock_available = stock_available(stock, product)
    if product_stock_available >= quantity

    else
      product.ingredients.each do |ingredient|
        product_in_sale = ingredient.item.product_in_sales.order('average_time ASC').first
        maximum_time_to_produce = [maximum_time_to_produce, product_in_sale.average_time].max
        purchase_items.push({ producer_id: product_in_sale.producer.producer_id, sku: product_in_sale.product.sku, quantity: ingredient.quantity, produce_time: product_in_sale.average_time })
      end
    end
    return {
        :maximum_time => maximum_time_to_produce,
        :purchase_items => purchase_items,
    }
  end

  def self.purchase_stock(purchase_item)
    failed = false
    purchase_item.each do |item|
      if buy_to_producer(item[:sku], item[:quantity], item[:producer_id], item[:produce_time])
      else
        failed = true
      end
    end
    return !failed
  end

  def self.buy_to_producer(sku, quantity, producer_id, produce_time)
    return PurchaseOrder.create_new_purchase_order(
        producer_id,
        sku,
        (Time.now + produce_time.to_f.hours).to_i * 1000,
        quantity.to_i,
        1, #TODO: Completar esto
        'contra_despacho' #TODO: Completar esto
    )
  end

end
