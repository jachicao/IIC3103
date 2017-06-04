class UpdatePurchaseOrdersStatusWorker
  include Sidekiq::Worker

  def perform(*args)
    PurchaseOrder.all.each do |purchase_order|
      server = GetPurchaseOrderJob.perform_now(purchase_order.po_id)
      if server[:code] == 200
        body = server[:body]
        puts 'server body: '
        puts body
        if body != nil
          purchase_order.update(client_id: body[:cliente],
                                supplier_id: body[:proveedor],
                                delivery_date: DateTime.parse(body[:fechaEntrega]),
                                unit_price: body[:precioUnitario],
                                sku: body[:sku],
                                quantity: body[:cantidad],
                                status: body[:estado])
        else
          purchase_order.destroy
        end
      else
        purchase_order.destroy
      end
    end
  end
end
