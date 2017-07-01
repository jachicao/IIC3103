class AzureInvoiceOverTime < SecondBase::Base
  belongs_to :azure_invoice
  belongs_to :azure_date
end