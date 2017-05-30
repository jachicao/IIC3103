class Product < ApplicationRecord
  has_many :ingredients
  has_many :product_in_sales

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


  def get_factory_analysis(quantity)
    total_not_despacho = StoreHouse.get_stock_total_not_despacho(sku)
    if total_not_despacho.nil?
      return nil
    end
    difference = quantity - total_not_despacho
    if difference <= 0
      return {
          :quantity => 0,
          :produce_time => 0,
          :price => 0,
      }
    else
      me = Producer.get_me
      produce_time = 0
      me.product_in_sales.each do |product_in_sale|
        if product_in_sale.product.sku == sku
          produce_time = product_in_sale.average_time
          break
        end
      end
      return {
          :quantity => lote * (difference.to_f / lote.to_f).ceil,
          :produce_time => produce_time,
          :price => unit_cost,
      }
    end
  end

  def buy_to_factory(quantity)
    FactoryOrder.make_product(sku, quantity, unit_cost)
  end

  def get_producer_analysis(producer, quantity)
    total_not_despacho = StoreHouse.get_stock_total_not_despacho(sku)
    if total_not_despacho.nil?
      return nil
    end
    difference = quantity - total_not_despacho
    if difference <= 0
      return {
          :quantity => 0,
          :produce_time => 0,
          :price => 0,
      }
    else
      produce_time = 0
      producer.product_in_sales.each do |product_in_sale|
        if product_in_sale.product.sku == sku
          produce_time = product_in_sale.average_time
          break
        end
      end
      return {
          :quantity => difference,
          :produce_time => produce_time,
          :price => unit_cost, #TODO
      }
      end
  end

  def buy_to_producer(producer, quantity, price, produce_time)
    return PurchaseOrder.create_new_purchase_order(
        producer.producer_id,
        sku,
        (Time.now + produce_time.to_f.hours).to_i * 1000,
        quantity,
        price,
        'contra_despacho' #TODO: Completar esto
    )
  end

  def get_ingredients_analysis(quantity)
    purchase_ingredients = []
    produce_time = 0
    unit_lote = (quantity.to_f / lote.to_f).ceil
    self.ingredients.each do |ingredient|
      producer_id = nil
      ingredient_quantity = 0
      ingredient_produce_time = 0
      ingredient_price = 0
      me = false
      buy = false
      ingredient.item.product_in_sales.each do |product_in_sale|
        if product_in_sale.is_mine
          analysis = ingredient.item.get_factory_analysis(ingredient.quantity * unit_lote)
          if analysis.nil?
            return nil
          end
          me = true
          if analysis[:quantity] == 0
          else
            buy = true
            producer_id = product_in_sale.producer.producer_id
            ingredient_produce_time = analysis[:produce_time]
            ingredient_price = analysis[:price]
            produce_time = [produce_time, ingredient_produce_time].max
            ingredient_quantity = analysis[:quantity]
          end
          break
        end
      end
      if me
      else
        ingredient.item.product_in_sales.each do |product_in_sale|
          if product_in_sale.is_mine
          else
            analysis = ingredient.item.get_producer_analysis(product_in_sale.producer, ingredient.quantity * unit_lote)
            if analysis.nil?
              return nil
            end
            if analysis[:quantity] == 0
            else
              if producer_id == nil or (ingredient_produce_time < analysis[:produce_time])
                buy = true
                producer_id = product_in_sale.producer.producer_id
                ingredient_price = analysis[:price]
                ingredient_produce_time = analysis[:produce_time]
                produce_time = [produce_time, ingredient_produce_time].max
                ingredient_quantity = analysis[:quantity]
              end
            end
          end
        end
      end
      if buy
        purchase_ingredients.push(producer_id: producer_id, quantity: ingredient_quantity, produce_time: ingredient_produce_time, sku: ingredient.item.sku, price: ingredient_price)
      end
    end
    return {
        :produce_time => produce_time,
        :quantity => unit_lote,
        :purchase_ingredients => purchase_ingredients,
    }
  end

  def produce_product(quantity)
    pending_product = PendingProduct.create(product: self, quantity: quantity)
    self.ingredients.each do |ingredient|
      pending_product.purchased_products.create(product: ingredient.item)
    end
  end

  def purchase_ingredients(ingredients)
    me = Producer.get_me
    ingredients.each do |ingredient|
      item = Product.all.find_by(sku: ingredient[:sku])
      producer = Producer.all.find_by(producer_id: ingredient[:producer_id])
      if me.producer_id == producer.producer_id
        item.buy_to_factory(ingredient[:quantity])
      else
        item.buy_to_producer(producer, ingredient[:quantity], ingredient[:price], ingredient[:produce_time])
      end
    end
  end

end