class Bank < ApplicationRecord

  def self.get_bank_id
    return ENV['BANK_ID']
  end

  def self.get_bank_accounts
    return GetBankAccountJob.perform_now[:body]
  end

  def self.get_transactions
    return GetBankTransactionsJob.perform_now(self.get_bank_id, DateTime.now - 365, DateTime.now)[:body][:data]
  end

  def self.get_transaction(id)
    return GetBankTransactionJob.perform_now(id)
  end

  def self.get_balance
    balance = 0
    transactions = get_transactions
    transactions.each do |transaction|
      balance += transaction[:monto]
    end
    return balance
  end
end