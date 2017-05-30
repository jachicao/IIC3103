class Bank < ApplicationRecord
  def self.get_bank_accounts
    return GetBankAccountJob.perform_now[:body]
  end

  def self.get_transactions
    return GetBankTransactionsJob.perform_now(ENV['BANK_ID'], DateTime.now - 90, DateTime.now)[:body][:data]
  end

  def self.get_transaction(id)
    return GetBankTransactionJob.perform_now(id)[:body]
  end

  def self.transfer_money(amount, source, target)
    return MakeBankTransactionJob.perform_now(amount, source, target)[:body]
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