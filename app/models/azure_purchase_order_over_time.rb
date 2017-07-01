class AzurePurchaseOrderOverTime < SecondBase::Base
  belongs_to :azure_purchase_order
  belongs_to :azure_date
end