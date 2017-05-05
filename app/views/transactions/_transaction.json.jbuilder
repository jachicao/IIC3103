json.extract! transaction, :id, :originAccount, :destinationAccount, :amount, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
