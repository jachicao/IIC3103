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

  def buy(quantity)
    if self.is_mine
      if self.product.ingredients.size > 0
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
          PendingProduct.create(product: self.product, quantity: (quantity.to_f / self.product.lote.to_f).ceil)
        end
      else
        quantity = self.product.lote * (quantity.to_f / self.product.lote.to_f).ceil
        BuyProductToFactoryWorker.perform_async(self.product.sku, quantity, self.product.unit_cost)
      end
    else
      BuyProductToBusinessWorker.perform_async(
          self.producer.producer_id,
          self.product.sku,
          (Time.now + (self.average_time * 3).to_f.hours).to_i * 1000, #TODO, REDUCE TIME
          quantity,
          self.price,
          'contra_factura'
      )
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
                purchase_items.push({ :success => false, :sku => ingredient.item.sku })
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
              :time => self.average_time + extra_time,
              :purchase_items => purchase_items,
          }
        else
          return {
              :success => true,
              :id => self.id,
              :quantity => quantity,
              :time => self.average_time,
          }
        end
      else
        if self.stock >= quantity and not self.producer.has_wrong_purchase_orders_api
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
