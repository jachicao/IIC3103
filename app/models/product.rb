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

  def produced_by_me
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
        if purchase_order.dispatched
        else
          if purchase_order.status == 'aceptada'
            total -= (purchase_order.quantity - purchase_order.quantity_dispatched)
          end
        end
      end
    end

    return total
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
    pending_product = PendingProduct.create(product: self, quantity: (quantity.to_f / self.lote.to_f).ceil)
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
      my_product_in_sale = get_my_product_sale
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
        best_product_in_sale_price = 0
        self.product_in_sales.each do |product_in_sale|
          if product_in_sale.is_mine
          else
            if product_in_sale.producer.has_wrong_api
            else
              producer_details = product_in_sale.producer.get_product_details(self.sku)
              if producer_details[:stock] >= difference
                if best_product_in_sale.nil? || best_product_in_sale_price > producer_details[:precio]
                  best_product_in_sale = product_in_sale
                  best_product_in_sale_price = producer_details[:precio]
                end
              end
            end
          end
        end
        if best_product_in_sale != nil
          return {
              :sku => self.sku,
              :quantity => difference,
              :buy => true,
              :success => true,
              :producer_id => best_product_in_sale.producer.producer_id,
              :price => best_product_in_sale_price,
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

  def analyze_min_stock(my_products, quantity)
    my_products.each do |p|
      if p[:sku] == self.sku
        difference = [quantity, 5000].min - p[:stock]
        if difference > 0
          if self.produced_by_me
            if self.ingredients.size > 0
              unit_lote = (difference.to_f / self.lote.to_f).ceil
              has_enough = true
              self.ingredients.each do |ingredient|
                stock_ingredient = 0
                my_products.each do |p_stock|
                  if p_stock[:sku] == ingredient.item.sku
                    stock_ingredient = p_stock[:stock]
                  end
                end
                ingredient_quantity = ingredient.quantity * unit_lote - stock_ingredient
                if ingredient_quantity > 0
                  has_enough = false
                end
              end
              if has_enough
                puts 'produciendo ' + difference.to_s + ' de ' + self.name
                self.produce(difference)
              else
                self.ingredients.each do |ingredient|
                  ingredient.item.analyze_min_stock(my_products, ingredient.quantity * unit_lote)
                end
              end
            else
              puts 'enviando a fabricar ' + difference.to_s + ' de ' + self.name
              self.buy_to_factory(difference)
            end
          else
            best_product_in_sale = nil
            best_product_in_sale_price = 0
            self.product_in_sales.each do |product_in_sale|
              if product_in_sale.is_mine
              else
                if product_in_sale.producer.has_wrong_api
                else
                  producer_details = product_in_sale.producer.get_product_details(self.sku)
                  if producer_details[:stock] >= difference
                    if best_product_in_sale.nil? || best_product_in_sale_price > producer_details[:precio]
                      best_product_in_sale = product_in_sale
                      best_product_in_sale_price = producer_details[:precio]
                    end
                  end
                end
              end
            end
            if best_product_in_sale != nil
              puts 'comprando ' + difference.to_s + ' de ' + self.name
              self.buy_to_producer(
                  best_product_in_sale.producer.producer_id,
                  difference,
                  best_product_in_sale_price,
                  best_product_in_sale.average_time)
            end
          end
        end
      end
    end
  end
end
