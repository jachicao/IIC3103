class DashboardController < ApplicationController


    def get_store_houses_report
      return StoreHouse.all
    end

    def get_products_report
      result = []
      me = Producer.get_me
      me.product_in_sales.each do |product_in_sale|
        product = product_in_sale.product
        result.push({ sku: product.sku, name: product.name, stock: product.stock, stock_available: product.stock_available })
      end
      return result
    end

    def get_set_factory_orders
      return FactoryOrder
    end

    def get_bills
      return Invoice.where(is_bill: true)
    end

    def get_cartola
      return Bank.get_transactions
    end

    def failed_transactions
      return FailedTransaction.all
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
        if t[:origen] == Bank.get_bank_id
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
