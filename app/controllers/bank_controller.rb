class BankController < ApplicationController

  def index
    @accounts = Bank.get_bank_accounts
  end

  def show
    @id = params[:id]
    @transactions = Bank.get_transactions_from_id(@id)
  end
end