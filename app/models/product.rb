class Product < ApplicationRecord
  has_many :ingredients
  has_many :product_in_sales
  has_many :stocks
  has_many :purchase_orders
  has_many :factory_orders

  def get_my_product_sale
    self.product_in_sales.each do |product_in_sale|
      if product_in_sale.is_mine
        return product_in_sale
      end
    end
    return nil
  end

  def is_produced_by_me
    self.product_in_sales.each do |product_in_sale|
      if product_in_sale.is_mine
        return true
      end
    end
    return false
  end

  def stock
    total = 0
    self.stocks.each do |s|
      total += s.quantity
    end
    return total
  end

  def stock_available
    total = self.stock
    PendingProduct.all.each do |pending_product|
      pending_product.product.ingredients do |ingredient|
        if ingredient.item.sku == self.sku
          total -= ingredient.quantity * pending_product.quantity
        end
      end
    end
    self.purchase_orders.each do |purchase_order|
      if purchase_order.is_made_by_me
      else
        if purchase_order.is_dispatched
        else
          if purchase_order.is_accepted
            total -= (purchase_order.quantity - purchase_order.server_quantity_dispatched)
          end
        end
      end
    end

    return [total, 0].max
  end

  def stock_in_despacho
    total = 0
    self.stocks.each do |s|
      if s.store_house.despacho
        total += s.quantity
      end
    end
    return total
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
    quantity = self.lote * (quantity.to_f / self.lote.to_f).ceil
    puts 'Produciendo ' + quantity.to_s + ' de ' + self.name
    if quantity > 5000
      return false
    end
    BuyProductToFactoryWorker.perform_async(self.sku, quantity, self.unit_cost)
    return true
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
      best_product_in_sale = nil
      producer.product_in_sales.each do |product_in_sale|
        if product_in_sale.product.sku == sku
          best_product_in_sale = product_in_sale
          break
        end
      end

      return {
          :quantity => quantity,
          :time => best_product_in_sale.average_time,
          :producer_price => best_product_in_sale.price,
          :producer_stock => best_product_in_sale.stock,
      }
      end
  end

  def get_best_producer(quantity)
    best_product_in_sale = nil
    self.product_in_sales.each do |product_in_sale|
      if product_in_sale.is_mine
      else
        if best_product_in_sale.nil? || best_product_in_sale.average_time > product_in_sale.average_time
          best_product_in_sale = product_in_sale
        end
      end
    end
    if best_product_in_sale != nil
      return {
          :success => true,
          :time => best_product_in_sale.average_time,
          :price => best_product_in_sale.price,
          :stock => best_product_in_sale.stock,
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
      self.product_in_sales.each do |product_in_sale|
        if product_in_sale.is_mine
        else
          if best_product_in_sale.nil? || best_product_in_sale.average_time > product_in_sale.average_time
            best_product_in_sale = product_in_sale
          end
        end
      end
      if best_product_in_sale != nil
        return {
            :success => true,
            :quantity => difference,
            :time => best_product_in_sale.average_time,
            :price => best_product_in_sale.price,
            :stock => best_product_in_sale.stock,
            :producer_id => best_product_in_sale.producer.producer_id,
        }
      end
      return {
          :success => false,
      }
    end
  end

  def buy_to_producer(producer_id, quantity, price, time_to_produce)
    puts 'Comprando ' + quantity.to_s + ' de ' + self.name + ' a productor ' + producer_id
    return BuyProductToBusinessWorker.new.perform(
        producer_id,
        self.sku,
        (Time.now + (time_to_produce * 3 * 24).to_f.hours).to_i * 1000, #TODO: QUITAR ESTO
        quantity,
        price,
        'contra_factura'
    )
  end

  def buy_to_producer_async(producer_id, quantity, price, time_to_produce)
    puts 'Comprando ' + quantity.to_s + ' de ' + self.name + ' a productor ' + producer_id
    BuyProductToBusinessWorker.perform_async(
        producer_id,
        self.sku,
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
    puts 'Produciendo ' + quantity.to_s + ' de ' + self.name
    PendingProduct.create(product: self, quantity: (quantity.to_f / self.lote.to_f).ceil)
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

  def analyze_purchase_order(quantity)
    if quantity > 5000
      return {
          :sku => self.sku,
          :quantity => 0,
          :buy => false,
          :success => false,
      }
    end
    difference = quantity - self.stock_available
    if difference > 0
      my_product_in_sale = self.get_my_product_sale
      if my_product_in_sale != nil
        if self.ingredients.size > 0
          unit_lote = (difference.to_f / self.lote.to_f).ceil
          has_enough = true
          self.ingredients.each do |ingredient|
            ingredient_quantity = ingredient.quantity * unit_lote - ingredient.item.stock_available
            if ingredient_quantity > 0
              has_enough = false
            end
          end
          if has_enough
            return {
                :sku => self.sku,
                :quantity => difference,
                :buy => true,
                :success => true,
                :producer_id => my_product_in_sale.producer.producer_id,
                :time => my_product_in_sale.average_time,
            }
          else
            purchase_items = []
            self.ingredients.each do |ingredient|
              purchase_items.push(ingredient.item.analyze_purchase_order(ingredient.quantity * unit_lote))
            end
            buy = false
            success = true
            extra_time = 0
            purchase_items.each do |p|
              if p[:success]
              else
                success = false
              end
              if p[:buy]
                buy = true
              end
              if p[:time] != nil
                extra_time = [extra_time, p[:time]].max
              end
            end
            return {
                :sku => self.sku,
                :quantity => difference,
                :buy => buy,
                :success => success,
                :producer_id => my_product_in_sale.producer.producer_id,
                :time => my_product_in_sale.average_time + extra_time,
                :purchase_items => purchase_items,
            }
          end
        else
          return {
              :sku => self.sku,
              :quantity => difference,
              :buy => true,
              :success => true,
              :producer_id => my_product_in_sale.producer.producer_id,
              :time => my_product_in_sale.average_time,
          }
        end
      else
        best_product_in_sale = nil
        self.product_in_sales.each do |product_in_sale|
          if product_in_sale.is_mine
          else
            if product_in_sale.producer.has_wrong_purchase_orders_api
            else
              if product_in_sale.stock >= difference
                if best_product_in_sale.nil? || best_product_in_sale.average_time > product_in_sale.average_time
                  best_product_in_sale = product_in_sale
                end
              end
            end
          end
        end
        best_product_in_sale = nil #TODO: REMOVE THIS
        if best_product_in_sale != nil
          return {
              :sku => self.sku,
              :quantity => difference,
              :buy => true,
              :success => true,
              :producer_id => best_product_in_sale.producer.producer_id,
              :price => best_product_in_sale.price,
              :time => 0,
          }
        else
          return {
              :sku => self.sku,
              :quantity => difference,
              :buy => true,
              :success => false,
          }
        end
      end
    else
      return {
          :sku => self.sku,
          :quantity => 0,
          :buy => false,
          :success => true,
          :time => 0,
      }
    end
  end

  def buy(quantity)
    if self.is_produced_by_me
      if self.ingredients.size > 0
        unit_lote = (quantity.to_f / self.lote.to_f).ceil
        lotes = unit_lote
        self.ingredients.each do |ingredient|
          ingredient_lotes = 0
          stock_available = ingredient.item.stock_available
          for i in 0..unit_lote - 1
            if stock_available >= ingredient.quantity
              ingredient_lotes += 1
              stock_available -= ingredient.quantity
            else
              break
            end
          end
          lotes = [lotes, ingredient_lotes].min
        end
        if lotes > 0
          self.produce(self.lote * lotes)
        end
      else
        self.buy_to_factory(quantity)
      end
    else
      self.product_in_sales.each do |product_in_sale|
        if product_in_sale.is_mine
        else
          if product_in_sale.producer.has_wrong_purchase_orders_api
          else
            self.buy_to_producer_async(
                product_in_sale.producer.producer_id,
                quantity,
                product_in_sale.price,
                product_in_sale.average_time)
          end
        end
      end
    end
  end
end
