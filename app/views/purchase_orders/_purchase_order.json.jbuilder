json.extract! purchase_order, :id, :po_id, :payment_method, :store_reception_id, :status, :created_at, :updated_at
json.url purchase_order_url(purchase_order, format: :json)
