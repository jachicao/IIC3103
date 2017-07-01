class AzureInvoice < SecondBase::Base
  belongs_to :azure_purchase_order
  belongs_to :azure_bank_transaction
end