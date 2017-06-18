class BuyProductToFactoryWorker < ApplicationWorker

  def perform(sku, cantidad, costo_unitario)
    factory_response = self.get_factory_account
    factory_id = factory_response[:body][:cuentaId]
    transaction_response = self.transfer_money(factory_id, cantidad * costo_unitario)
    transaction_id = transaction_response[:body][:_id]
    return self.make_product(sku, cantidad, transaction_id)
  end
end