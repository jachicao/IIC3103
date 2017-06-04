class Product < ApplicationRecord
  has_many :ingredients
  has_many :product_in_sales

  def update_stock_available
    if $updating_stock != nil
      return
    end
    $updating_stock = true
    UpdateStockAvailableWorker.perform_async
    $updating_stock = nil
  end

  def get_stock
    key = 'available_stock'
    cache = $redis.get(key)
    if cache != nil
      json = JSON.parse(cache, symbolize_names: true)
      json.each do |p|
        if p[:sku] == self.sku
          return p[:stock]
        end
      end
    else
      update_stock_available
    end
    return 0
  end

  def get_stock_available
    key = 'available_stock'
    cache = $redis.get(key)
    if cache != nil
      json = JSON.parse(cache, symbolize_names: true)
      json.each do |p|
        if p[:sku] == self.sku
          return p[:stock_available]
        end
      end
    else
      update_stock_available
    end
    return 0
  end

  def get_max_production(quantity)
    total_not_despacho = StoreHouse.get_stock_total_not_despacho(sku)
    if total_not_despacho.nil?
      return nil
    end

    difference = 5000 - total_not_despacho
    puts difference
    if difference < quantity
      return {
          :quantity => 0,
          :time => 0,
      }
    else
      me = Producer.get_me
      time = 0
      me.product_in_sales.each do |product_in_sale|
        if product_in_sale.product.sku == sku
          time = product_in_sale.average_time
          break
        end
      end
      return {
          :quantity => self.lote * (quantity / self.lote.to_f).ceil,
          :time => time,
      }
    end
  end

  def get_factory_analysis(quantity)
    total_not_despacho = StoreHouse.get_stock_total_not_despacho(sku)
    if total_not_despacho.nil?
      return nil
    end
    difference = quantity - total_not_despacho
    if difference <= 0
      return {
          :success => true,
          :quantity => 0,
          :time => 0,
      }
    else
      me = Producer.get_me
      time = 0
      me.product_in_sales.each do |product_in_sale|
        if product_in_sale.product.sku == sku
          time = product_in_sale.average_time
          break
        end
      end
      return {
          :success => true,
          :quantity => self.lote * (difference.to_f / self.lote.to_f).ceil,
          :time => time,
      }
    end
  end

  def buy_to_factory(quantity)
    FactoryOrder.make_product(sku, self.lote * (quantity.to_f / self.lote.to_f).ceil, unit_cost)
  end

  def get_max_purchase_analysis(producer, quantity)
    total_not_despacho = StoreHouse.get_stock_total_not_despacho(sku)
    if total_not_despacho.nil?
      return nil
    end
    difference = 5000 - total_not_despacho
    puts difference
    if difference < quantity
      return {
          :quantity => 0,
          :time => 0,
          :producer_price => 0,
          :producer_stock => 0,
      }
    else
      time = 0
      producer.product_in_sales.each do |product_in_sale|
        if product_in_sale.product.sku == sku
          time = product_in_sale.average_time
          break
        end
      end
      producer_details = producer.get_product_details(sku)

      return {
          :quantity => quantity,
          :time => time,
          :producer_price => producer_details[:precio],
          :producer_stock => producer_details[:stock],
      }
      end
  end

  def get_best_producer(quantity)
    best_product_in_sale = nil
    best_product_price = nil
    best_product_stock = nil
    self.product_in_sales.each do |product_in_sale|
      if product_in_sale.is_mine
      else
        producer_details = product_in_sale.producer.get_product_details(self.sku)
        invalid_groups = [4, 6, 8] #TODO: remove this
        if !(invalid_groups.include?(product_in_sale.producer.group_number))
          if best_product_in_sale.nil? || best_product_in_sale.average_time > product_in_sale.average_time
            best_product_in_sale = product_in_sale
            best_product_price = producer_details[:precio]
            best_product_stock = producer_details[:stock]
          end
        end
=begin
          if producer_details[:stock] >= quantity
            if best_product_in_sale.nil? || best_product_in_sale.average_time > product_in_sale.average_time
              best_product_in_sale = product_in_sale
              best_product_price = producer_details[:precio]
              best_product_stock = producer_details[:stock]
            end
          end
=end
      end
    end
    if best_product_in_sale != nil
      return {
          :success => true,
          :time => best_product_in_sale.average_time,
          :price => best_product_price,
          :stock => best_product_stock,
          :producer_id => best_product_in_sale.producer.producer_id,
      }
    end
    return {
        :success => false,
    }
  end

  def get_best_producer_analysis(quantity)
    total_not_despacho = StoreHouse.get_stock_total_not_despacho(sku)
    if total_not_despacho.nil?
      return nil
    end
    difference = quantity - total_not_despacho
    if difference <= 0
      return {
          :success => true,
          :quantity => 0,
          :time => 0,
      }
    else
      best_product_in_sale = nil
      best_product_price = nil
      best_product_stock = nil
      self.product_in_sales.each do |product_in_sale|
        if product_in_sale.is_mine
        else
          producer_details = product_in_sale.producer.get_product_details(self.sku)
          if best_product_in_sale.nil? || best_product_in_sale.average_time > product_in_sale.average_time
            best_product_in_sale = product_in_sale
            best_product_price = producer_details[:precio]
            best_product_stock = producer_details[:stock]
          end
=begin
          if producer_details[:stock] >= difference
            if best_product_in_sale.nil? || best_product_in_sale.average_time > product_in_sale.average_time
              best_product_in_sale = product_in_sale
              best_product_price = producer_details[:precio]
              best_product_stock = producer_details[:stock]
            end
          end
=end
        end
      end
      if best_product_in_sale != nil
        return {
            :success => true,
            :quantity => difference,
            :time => best_product_in_sale.average_time,
            :price => best_product_price,
            :stock => best_product_stock,
            :producer_id => best_product_in_sale.producer.producer_id,
        }
      end
      return {
          :success => false,
      }
    end
  end

  def buy_to_producer(producer_id, quantity, price, time_to_produce)
    return PurchaseOrder.create_new_purchase_order(
        producer_id,
        sku,
        (Time.now + (time_to_produce * 3 * 24).to_f.hours).to_i * 1000, #TODO: QUITAR ESTO
        quantity,
        price,
        'contra_factura'
    )
  end

  def get_ingredients_analysis(quantity)
    purchase_ingredients = []
    time = 0
    unit_lote = (quantity.to_f / lote.to_f).ceil
    self.ingredients.each do |ingredient|
      producer_id = nil
      ingredient_quantity = 0
      ingredient_time = 0
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
            ingredient_time = analysis[:time]
            time = [time, ingredient_time].max
            ingredient_quantity = analysis[:quantity]
          end
          break
        end
      end
      if me
      else
        analysis = ingredient.item.get_best_producer_analysis(ingredient.quantity * unit_lote)
        if analysis.nil?
          return nil
        end
        if analysis[:success]
          if analysis[:quantity] > 0
            buy = true
            producer_id = analysis[:producer_id]
            ingredient_time = analysis[:time]
            time = [time, ingredient_time].max
            ingredient_quantity = analysis[:quantity]
          end
        else
          return {
              :success => false,
          }
        end
      end
      if buy
        purchase_ingredients.push(producer_id: producer_id, quantity: ingredient_quantity, time: ingredient_time, sku: ingredient.item.sku)
      end
    end
    return {
        :success => true,
        :time => time,
        :quantity => unit_lote,
        :purchase_ingredients => purchase_ingredients,
    }
  end

  def produce(quantity)
    pending_product = PendingProduct.create(product: self, quantity: quantity)
    self.ingredients.each do |ingredient|
      pending_product.purchased_products.create(product: ingredient.item)
    end
  end

  def purchase_ingredients(ingredients)
    me = Producer.get_me
    ingredients.each do |ingredient|
      item = Product.find_by(sku: ingredient[:sku])
      if me.producer_id == ingredient[:producer_id]
        item.buy_to_factory(ingredient[:quantity])
      else
        item.buy_to_producer(ingredient[:producer_id], ingredient[:quantity], item.unit_cost, ingredient[:time]) #TODO
      end
    end
  end

end
