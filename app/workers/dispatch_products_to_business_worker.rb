class DispatchProductsToBusinessWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(po_id)
    puts 'starting DispatchProductsToBusinessWorker'
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil
      quantity_left = purchase_order.quantity - purchase_order.server_quantity_dispatched
      if quantity_left > 0
        puts 'DispatchProductsToBusinessWorker: quantity left ' + quantity_left.to_s
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
                quantity_moved = 0
                products[:body].each do |p|
                  product_id = p[:_id]
                  quantity_moved += 1
                  DispatchProductToBusinessWorker.perform_async(po_id, product_id, from_store_house_id, despacho_id)
                end
                quantity_left -= quantity_moved
              end
            end
          end
        end
        DispatchProductsToBusinessWorker.perform_in(2.minutes, po_id)
      end
    end
  end
end
