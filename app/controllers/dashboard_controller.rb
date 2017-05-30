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
      bills = Invoice.where(is_bill: true).all
      return bills
    end

    def get_cartola
      transactions = GetBankTransactionsJob.perform_now(ENV['BANK_ID'], 6.months.ago.to_date.to_s, Date.tomorrow.to_s)
      return transactions[:data]
    end

    def index
      @almacenes = get_store_houses_report
      @productos = get_products_report
      @factory_orders = get_set_factory_orders
      @bills = get_bills
      @transactions = get_cartola
    end
    
end
