class DashboardController < ApplicationController


    def get_store_houses_report
      return StoreHouse.all
    end

    def get_products_report
      result = []
      Product.all.each do |product|
        if product.is_produced_by_me
          result.push({ sku: product.sku, name: product.name, stock: product.stock, stock_available: product.stock_available })
        elsif product.stock > 0
          result.push({ sku: product.sku, name: product.name, stock: product.stock, stock_available: product.stock_available })
        end
      end
      return result
    end

    def get_set_factory_orders
      return FactoryOrder.all
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
