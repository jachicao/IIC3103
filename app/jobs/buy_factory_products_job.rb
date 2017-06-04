class BuyFactoryProductsJob < ApplicationJob
  queue_as :default

  def perform(sku, cantidad, costo_unitario)
    factory_account = nil
    while factory_account.nil?
      factory_account = GetFactoryAccountJob.perform_now
      if factory_account.nil?
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    transaction = nil
    while transaction.nil?
      transaction = Bank.transfer_money(factory_account[:body][:cuentaId], cantidad * costo_unitario)
      if transaction.nil?
        sleep(5)
      end
    end
    MakeProductsJob.perform_later(sku, cantidad, transaction[:body][:_id])
  end
end
