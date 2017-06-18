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
      pending_product.product.ingredients.each do |ingredient|
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

  def analyze_purchase_order(quantity)
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
                :quantity => difference,
                :success => true,
                :buy => true,
                :id => my_product_in_sale.id,
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
                :quantity => difference,
                :success => success,
                :buy => buy,
                :id => my_product_in_sale.id,
                :time => my_product_in_sale.average_time + extra_time,
                :purchase_items => purchase_items,
            }
          end
        else
          return {
              :quantity => difference,
              :success => true,
              :buy => true,
              :id => my_product_in_sale.id,
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
              :quantity => difference,
              :success => true,
              :buy => true,
              :id => best_product_in_sale.id,
              :time => 0,
          }
        else
          return {
              :quantity => difference,
              :success => false,
              :buy => true,
              :time => 0,
          }
        end
      end
    else
      return {
          :quantity => 0,
          :success => true,
          :buy => false,
          :time => 0,
      }
    end
  end

  def buy_min_stock(quantity)
    my_product_in_sale = self.get_my_product_sale
    if my_product_in_sale != nil
      my_product_in_sale.buy_product(quantity)
    else
      self.product_in_sales.each do |product_in_sale|
        if product_in_sale.is_mine
        else
          if product_in_sale.producer.has_wrong_purchase_orders_api
          else
            product_in_sale.buy_product(quantity)
          end
        end
      end
    end
  end
end
