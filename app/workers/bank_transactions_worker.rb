class BankTransactionsWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(*args)
    Bank.get_transactions.each do |transaction|
      BankTransaction.find_or_create_by(_id: transaction[:_id]) do |bank_transaction|
        bank_transaction.from = transaction[:origen]
        bank_transaction.to = transaction[:destino]
        bank_transaction.amount = transaction[:monto]
        bank_transaction.created_at = DateTime.parse(transaction[:created_at])
        bank_transaction.updated_at = DateTime.parse(transaction[:updated_at])
      end
    end
  end
end