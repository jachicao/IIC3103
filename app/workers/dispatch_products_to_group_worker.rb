class DispatchProductsToGroupWorker
  include Sidekiq::Worker

  def perform(to_store_house_id, sku, quantity, po_id, price)

    all_stock = nil
    while all_stock.nil?
      all_stock = StoreHouse.all_stock
      if all_stock.nil?
        sleep(5)
      end
    end

    total_despacho = 0
    despacho_id = nil
    despachos = []
    not_despachos = []
    all_stock.each do |store_house|
      if store_house[:despacho]
        despacho_id = store_house[:_id]
        despachos.push(store_house)
      else
        not_despachos.push(store_house)
      end
      store_house[:inventario].each do |p|
        if p[:sku] == sku
          if store_house[:despacho]
            total_despacho += p[:total]
          end
        end
      end
    end
    if total_despacho < quantity
      StoreHouse.move_stock(not_despachos, despachos, sku, quantity - total_despacho)
    end
    MoveProductsBetweenGroupsJob.perform_later(despacho_id, to_store_house_id, sku, quantity, po_id, price)
  end
end
