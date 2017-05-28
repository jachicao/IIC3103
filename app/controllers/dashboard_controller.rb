class DashboardController < ApplicationController

    
    def get_store_houses_report
      return StoreHouse.all
    end

    def get_products_report

      me = Producer.get_me
      result = []
      me.product_in_sales.each do |product_in_sale|
        product = product_in_sale.product
        result.push({ sku: product.sku, name: product.name, stock: product.get_stock })
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

    def index
      @almacenes = get_store_houses_report
      @productos = get_products_report
      @factory_orders = get_set_factory_orders
    end
    
end
