class BuyFactoryProductsJob < ApplicationJob
  queue_as :default

  def perform(sku, cantidad, costo_unitario)
    response = GetFactoryAccountJob.perform_now()
    if response.nil?
      return { :error => 'Error en transferencia' }
    end
    factory_account = response[:body][:cuentaId]
    transaction = MakeBankTransactionJob.perform_now(cantidad * costo_unitario, ENV['BANK_ID'], factory_account)[:body]
    MakeProductsJob.perform_later(sku, cantidad, transaction[:_id])
  end
end
