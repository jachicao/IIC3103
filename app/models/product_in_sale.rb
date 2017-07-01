class ProductInSale < ApplicationRecord
  belongs_to :producer
  belongs_to :product

  def is_mine
    return self.producer.is_me
  end

  def self.get_mines
    result = []
    self.all.each do |product_in_sale|
      if product_in_sale.is_mine
        result.push(product_in_sale)
      end
    end
    return result
  end

  def get_price
    if self.is_mine
      return self.product.unit_cost
    else
      return self.price
    end
  end

  def produce_product(quantity)
    unit_lote = (quantity.to_f / self.product.lote.to_f).ceil
    lotes = unit_lote
    self.product.ingredients.each do |ingredient|
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
      puts 'Producing ' + quantity.to_s + ' of '  + self.product.name + ' to factory'
      PendingProduct.create(product: self.product, quantity: lotes)
      return { :success => true }
    end
    return { :success => false }
  end

  def buy_to_factory_sync(quantity)
    puts 'Buying ' + quantity.to_s + ' of '  + self.product.name + ' to factory'
    quantity = self.product.lote * (quantity.to_f / self.product.lote.to_f).ceil
    return BuyProductToFactoryWorker.new.perform(self.product.sku, quantity, self.product.unit_cost)
  end

  def get_delivery_time(quantity)
    unit_lote = (quantity.to_f / self.product.lote.to_f).ceil
    time = (self.average_time * unit_lote)
    time += (quantity.to_f / ENV['SERVER_RATE_LIMIT'].to_f).ceil / 60.to_f
    if self.producer.group_number == 2
      time = [time, 9].max
    end
    return time
  end

  def buy_to_producer_sync(quantity)
    puts 'Buying ' + quantity.to_s + ' of '  + self.product.name + ' to ' + self.producer.group_number
    return CreateBusinessPurchaseOrderWorker.new.perform(
        self.producer.producer_id,
        self.product.sku,
        (Time.now + self.get_delivery_time(quantity).to_f.hours).to_i * 1000, #TODO, REDUCE TIME
        quantity,
        self.price,
        'contra_despacho'
    )
  end

  def buy_product_sync(quantity)
    if self.is_mine
      if self.product.ingredients.size > 0
        return self.produce_product(quantity)
      else
        return self.buy_to_factory_sync(quantity)
      end
    else
      return buy_to_producer_sync(quantity)
    end
  end

  def buy_to_factory_async(quantity)
    puts 'Buying ' + quantity.to_s + ' of '  + self.product.name + ' to factory'
    quantity = self.product.lote * (quantity.to_f / self.product.lote.to_f).ceil
    BuyProductToFactoryWorker.perform_async(self.product.sku, quantity, self.product.unit_cost)
  end

  def buy_to_producer_async(quantity)
    puts 'Buying ' + quantity.to_s + ' of '  + self.product.name + ' to ' + self.producer.group_number
    CreateBusinessPurchaseOrderWorker.perform_async(
        self.producer.producer_id,
        self.product.sku,
        (Time.now + self.get_delivery_time(quantity).to_f.hours).to_i * 1000, #TODO, REDUCE TIME
        quantity,
        self.price,
        'contra_despacho'
    )
  end

  def buy_product_async(quantity)
    if self.is_mine
      if self.product.ingredients.size > 0
        self.produce_product(quantity)
      else
        self.buy_to_factory_async(quantity)
      end
    else
      buy_to_producer_async(quantity)
    end
  end

  def analyze_buy(quantity)
    if quantity > 5000
      return {
          :success => false,
          :id => self.id,
          :quantity => quantity,
          :time => 0,
      }
    elsif quantity > 0
      if self.is_mine
        unit_lote = (quantity.to_f / self.product.lote.to_f).ceil
        time = self.average_time * unit_lote
        quantity = self.product.lote * unit_lote
        if self.product.ingredients.size > 0
          purchase_items = []
          self.product.ingredients.each do |ingredient|
            quantity_needed = unit_lote * ingredient.quantity - ingredient.item.stock_available
            if quantity_needed > 0
              found = false
              ingredient.item.product_in_sales.each do |product_in_sale|
                result = product_in_sale.analyze_buy(quantity_needed)
                if result[:success]
                  purchase_items.push(result)
                  found = true
                  break
                end
              end
              if found
              else
                purchase_items.push({ :success => false })
              end
            end
          end
          success = true
          extra_time = 0
          purchase_items.each do |p|
            if p[:success]
            else
              success = false
            end
            if p[:time] != nil
              extra_time = [extra_time, p[:time]].max
            end
          end
          return {
              :success => success,
              :id => self.id,
              :quantity => quantity,
              :time => time + extra_time,
              :purchase_items => purchase_items,
          }
        else
          return {
              :success => true,
              :id => self.id,
              :quantity => quantity,
              :time => time,
          }
        end
      else
        if true#self.stock >= quantity and not self.producer.has_wrong_purchase_orders_api
          return {
              :success => true,
              :id => self.id,
              :quantity => quantity,
              :time => 0,
          }
        else
          return {
              :success => false,
              :id => self.id,
              :quantity => quantity,
              :time => self.average_time,
          }
        end
      end
    else
      return {
          :success => true,
          :id => self.id,
          :quantity => quantity,
          :time => 0,
      }
    end
  end
end
