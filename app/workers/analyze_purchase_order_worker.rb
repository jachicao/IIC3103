class AnalyzePurchaseOrderWorker
  include Sidekiq::Worker

  def buy(result)
    product = Product.find_by(sku: result[:sku])
    if result[:purchase_items] != nil
      result[:purchase_items].each do |p|
        self.buy(p)
      end
    end
    if result[:buy] and result[:success]
      my_product_in_sale = product.get_my_product_sale
      if my_product_in_sale != nil
        if my_product_in_sale.ingredients.size > 0
          product.produce(result[:quantity])
        else
          product.buy_to_factory(result[:quantity])
        end
      else
        product.buy_to_producer(
            result[:producer_id],
            result[:quantity],
            result[:price],
            result[:time]
        )
      end
    end
  end

  def perform(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order.supplier_id == ENV['GROUP_ID']
      my_product_in_sale = ProductInSale.get_my_product_in_sale(purchase_order.sku)
      if my_product_in_sale != nil
        if purchase_order.unit_price >= my_product_in_sale.price
          product = my_product_in_sale.product
          result = product.analyze_purchase_order(purchase_order.quantity)
          if result[:success]
            if (DateTime.current + result[:time].to_f.hours) <= purchase_order.delivery_date
              if result[:buy]
                buy(result)
              end
              purchase_order.accept_purchase_order
            else
              purchase_order.reject_purchase_order('Tiempo insuficiente')
            end
          else
            purchase_order.reject_purchase_order('Stock insuficiente')
          end
        else
          purchase_order.reject_purchase_order('Precio incorrecto')
        end
      else
        purchase_order.reject_purchase_order('SKU incorrecto')
      end
    else
      purchase_order.reject_purchase_order('Proveedor incorrecto')
    end
  end
end
