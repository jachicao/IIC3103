class DispatchProductToAddressWorker < ApplicationWorker
  sidekiq_options queue: 'low'

  def perform(po_id, product_id, from_store_house_id, despacho_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil and purchase_order.quantity > purchase_order.quantity_dispatched
      address = purchase_order.client_id
      sku = purchase_order.product.sku
      price = purchase_order.unit_price
      internal_result = MoveProductToStoreHouseWorker.new.perform(sku, product_id, from_store_house_id, despacho_id)
      if internal_result[:code] == 200
        while true
          external_result = MoveProductToAddressWorker.new.perform(sku, product_id, despacho_id, address, price, po_id)
          if external_result[:code] == 200
            break
          elsif external_result[:code] == 429
            sleep(5)
          else
            break #TODO
          end
        end
      end
    end
  end
end