class DispatchProductToBusinessWorker < ApplicationWorker
  sidekiq_options queue: 'low'

  def perform(po_id, product_id, from_store_house_id, despacho_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil and purchase_order.quantity > purchase_order.server_quantity_dispatched
      sku = purchase_order.product.sku
      price = purchase_order.unit_price
      to_store_house_id = purchase_order.store_reception_id
      internal_result = MoveProductToStoreHouseWorker.new.perform(sku, product_id, from_store_house_id, despacho_id)
      if internal_result[:code] == 200
        while true
          external_result = MoveProductToBusinessWorker.new.perform(sku, product_id, despacho_id, to_store_house_id, po_id, price)
          if external_result[:code] == 200
            break
          else
            sleep(5)
          end
        end
      end
    end
  end
end