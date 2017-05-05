json.extract! purchase_order, :id, :orderId, :channel, :supplier, :client, :sku, :quantity, :dispatchedQuantity, :unitPrice, :deadline, :state, :rejectionCause, :cancellationCause, :notes, :billId, :created_at, :updated_at
json.url purchase_order_url(purchase_order, format: :json)
