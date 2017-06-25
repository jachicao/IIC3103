class DispatchProductsToAddressWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil
      purchase_order.update_properties_sync
      quantity_left = purchase_order.quantity - purchase_order.quantity_dispatched
      if quantity_left > 0
        puts 'DispatchProductsToAddressWorker (' + po_id + '): quantity left ' + quantity_left.to_s
        despacho_id = StoreHouse.get_despacho._id
        product = purchase_order.product
        sku = product.sku
        product.stocks.each do |s|
          if s.store_house.despacho
          else
            if quantity_left > 0
              from_store_house_id = s.store_house._id
              limit = [quantity_left, s.quantity, 100].min
              products = self.get_product_stock(from_store_house_id, sku, limit)
              if products != nil
                products[:body].each do |p|
                  product_id = p[:_id]
                  if StoreHouse.can_send_request
                    quantity_left -= 1
                    DispatchProductToAddressWorker.perform_async(po_id, product_id, from_store_house_id, despacho_id)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
