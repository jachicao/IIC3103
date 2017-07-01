class WarehouseWorker < ApplicationWorker
  
  def get_azure_date(date)
    return AzureDate.find_or_create_by(date: date)
  end

  def perform(*args)
    if ENV['DOCKER_RUNNING'].nil?
      #return nil
    end
    current_time = self.get_azure_date(DateTime.current)
    puts current_time.as_json
    StoreHouse.all.each do |store_house|
      AzureStoreHouse.find_or_create_by(_id: store_house._id) do |azure_store_house|
        azure_store_house.total_space = store_house.total_space
        azure_store_house.store_type = store_house.type
      end
    end
    StoreHouse.all.each do |store_house|
      azure_store_house = AzureStoreHouse.find_by(_id: store_house._id)
      if azure_store_house != nil
        azure_store_house.update(used_space: store_house.used_space, available_space: store_house.available_space)
        azure_store_house_over_time = AzureStoreHouseOverTime.create(azure_store_house: azure_store_house, azure_date: current_time, used_space: store_house.used_space, available_space: store_house.available_space)
      end
    end
    Product.all.each do |product|
      AzureProduct.find_or_create_by(sku: product.sku) do |azure_product|
        azure_product.name = product.name
        azure_product.product_type = product.product_type
        azure_product.unit = product.unit
        azure_product.unit_cost = product.unit_cost
      end
    end
    Product.all.each do |product|
      azure_product = AzureProduct.find_by(sku: product)
      if azure_product != nil
        azure_product.update(stock: product.stock, stock_available: product.stock_available)
        azure_product_stock_over_time = AzureProductStockOverTime.create(azure_date: current_time, azure_product: azure_product, stock: product.stock, stock_available: product.stock_available)
      end
    end
    BankTransaction.all.each do |bank_transaction|
      AzureBankTransaction.find_or_create_by(_id: bank_transaction._id) do |azure_bank_transaction|
        azure_bank_transaction.from = bank_transaction.from
        azure_bank_transaction.to = bank_transaction.to
        azure_bank_transaction.amount = bank_transaction.amount
        azure_bank_transaction.created_at = bank_transaction.created_at
        azure_bank_transaction.updated_at = bank_transaction.updated_at
      end
    end
    PurchaseOrder.all.each do |purchase_order|
      AzurePurchaseOrder.find_or_create_by(_id: purchase_order.po_id) do |azure_purchase_order|
        azure_purchase_order.azure_product = AzureProduct.find_by(sku: purchase_order.product.sku)
        azure_purchase_order.payment_method = purchase_order.payment_method
        azure_purchase_order.store_reception_id = purchase_order.store_reception_id
        azure_purchase_order.quantity = purchase_order.quantity
        azure_purchase_order.client = purchase_order.get_client
        azure_purchase_order.supplier = purchase_order.get_supplier
        azure_purchase_order.unit_price = purchase_order.unit_price
        azure_purchase_order.delivery_date = purchase_order.delivery_date
        azure_purchase_order.channel = purchase_order.channel
        azure_purchase_order.created_at = purchase_order.created_at
        azure_purchase_order.updated_at = purchase_order.updated_at
      end
    end
    PurchaseOrder.all.each do |purchase_order|
      azure_purchase_order = AzurePurchaseOrder.find_by(_id: purchase_order.po_id)
      if azure_purchase_order != nil
        azure_purchase_order.update(status: purchase_order.status, quantity_dispatched: purchase_order.quantity_dispatched)
        azure_purchase_order_over_time = AzurePurchaseOrderOverTime.create(azure_date: current_time, azure_purchase_order: azure_purchase_order, status: purchase_order.status, quantity_dispatched: purchase_order.quantity_dispatched)
      end
    end
    Invoice.all.each do |invoice|
      AzureInvoice.find_or_create_by(_id: invoice._id) do |azure_invoice|
        azure_invoice.po_id = invoice.po_id
        azure_invoice.client = invoice.get_client
        azure_invoice.supplier = invoice.get_supplier
        azure_invoice.amount = invoice.amount
        azure_invoice.created_at = invoice.created_at
        azure_invoice.updated_at = invoice.updated_at
      end
    end
    Invoice.all.each do |invoice|
      azure_invoice = AzureInvoice.find_by(_id: invoice._id)
      if azure_invoice != nil
        azure_invoice.update(status: invoice.status)
        azure_bank_transaction = AzureBankTransaction.find_by(_id: invoice.trx_id)
        if azure_bank_transaction != nil
          azure_invoice.update(azure_bank_transaction: azure_bank_transaction)
        end
        azure_invoice_over_time = AzureInvoiceOverTime.create(azure_date: current_time, azure_invoice: azure_invoice, status: invoice.status)
      end
    end
  end
end