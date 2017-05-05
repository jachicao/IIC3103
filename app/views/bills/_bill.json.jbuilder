json.extract! bill, :id, :supplier, :client, :grossValue, :iva, :totalValue, :paymentStatus, :pushaseOrderId, :paymentDeadline, :rejectionCause, :cancellationCause, :created_at, :updated_at
json.url bill_url(bill, format: :json)
