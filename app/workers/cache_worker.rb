class CacheWorker
  include Sidekiq::Worker

  def perform(*args)
    store_houses = StoreHouse.all
    if store_houses != nil
      store_houses.each do |store_house|
        StoreHouse.get_stock(store_house[:_id])
      end
    end
    PurchaseOrder.all.each do |purchase_order|
      PurchaseOrder.get_server_details(purchase_order.po_id)
    end
    Bank.get_transactions
    Producer.all.each do |producer|
      if producer.is_me
      else
        GetGroupPricesJob.perform_now(producer.group_number)
      end
    end
  end
end
