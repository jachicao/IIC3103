class AzureProductStockOverTime < SecondBase::Base
  belongs_to :azure_product
  belongs_to :azure_date
end