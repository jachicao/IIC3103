class DashboardController < ApplicationController


    def get_store_houses_report
      return StoreHouse.all
    end

    def get_products_report
      me = Producer.get_me
      my_products = []
      me.product_in_sales.each do |product_in_sale|
        my_products[product_in_sale.product.sku.to_i] = true
      end

      products = []
      Product.all.each do |product|
        products[product.sku.to_i] = { sku: product.sku, name: product.name, stock: 0 }
      end

      almacenes = StoreHouse.all_stock

      if almacenes == nil
        return nil
      end

      almacenes.each do |almacen|
        almacen[:inventario].each do |p|
          product = products[p[:sku].to_i]
          if product != nil
            product[:stock] += p[:total]
          end
        end
      end

      result = []

      products.each do |product|
        if product != nil and (product[:stock] > 0 or my_products[product[:sku].to_i])
          result.push(product)
        end
      end

      return result
    end

    def get_set_factory_orders
      result = []

      FactoryOrder.all.each do |f|
        result.push({ sku: f.sku, quantity: f.quantity, available: f.available })
      end

      return result
    end

    def get_bills
      return Invoice.where(is_bill: true)
    end

    def get_cartola
      return Bank.get_transactions
    end

    def failed_transactions
      return Failedtransaction.all
    end

    def index
      @almacenes = get_store_houses_report
      @productos = get_products_report
      @factory_orders = get_set_factory_orders
      @bills = get_bills
      @transferencias = get_cartola
      @failed = failed_transactions
      @transactions = []
      @transferencias.each do |t|
        if t[:origen] == ENV['BANK_ID']
          if @transactions == []
            @transactions.push(t)
          else
            contador = 0
            @transactions.each do |trx|
              if trx[:_id] == t[:_id]
                contador += 1
              end
            end
            if contador == 0
              @transactions.push(t)
            end
          end
        end
      end
    end

end
