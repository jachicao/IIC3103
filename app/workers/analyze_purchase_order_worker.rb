class AnalyzePurchaseOrderWorker
  include Sidekiq::Worker

  def perform(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order.supplier_id == ENV['GROUP_ID']
      product_in_sale = ProductInSale.get_my_product_in_sale(purchase_order.sku)
      if product_in_sale != nil
        if purchase_order.unit_price >= product_in_sale.price
          product = product_in_sale.product
          quantity = purchase_order.quantity
          produce_time = 0
          if product.ingredients.size > 0
            produce_time = product.get_ingredients_analysis(quantity)[:produce_time]
          else
            produce_time = product.get_factory_analysis(quantity)[:produce_time]
          end
          if (DateTime.current + produce_time.to_f.hours) <= purchase_order.delivery_date
            purchase_order.accept_purchase_order
          else
            purchase_order.reject_purchase_order('Tiempo insuficiente')
          end
        else
          purchase_order.reject_purchase_order('Precio incorrecto')
        end
      else
        purchase_order.reject_purchase_order('SKU incorrecto')
      end
    else
      purchase_order.reject_purchase_order('proveedor incorrecto')
    end
  end
end
