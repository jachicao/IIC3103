rails generate second_base:migration CreateAzureStoreHouse _id:string:index total_space:integer store_type:string 

rails generate second_base:migration CreateAzureProduct sku:string:index name:string product_type:string unit:string unit_cost:integer 

rails generate second_base:migration CreateAzureBankTransaction _id:string:index from:string to:string amount:integer created_at:datetime updated_at:datetime

rails generate second_base:migration CreateAzurePurchaseOrder azure_product:references _id:string:index payment_method:string store_reception_id:string quantity:integer client:string supplier:string unit_price:integer delivery_date:datetime channel:string created_at:datetime updated_at:datetime

rails generate second_base:migration CreateAzureInvoice azure_purchase_order:references azure_bank_transaction:references _id:string:index po_id:string client:string supplier:string amount:integer bank_id:string created_at:datetime updated_at:datetime

rails generate second_base:migration CreateAzureDate date:datetime description:string minute:integer hour:integer day:integer day_of_the_week:string day_of_the_year:integer week_of_the_year:integer month:string year:integer

rails generate second_base:migration CreateAzureStoreHouseOverTime azure_date:references azure_store_house:references used_space:integer available_space:integer

rails generate second_base:migration CreateAzureProductStockOverTime azure_date:references azure_product:references stock:integer stock_available:integer

rails generate second_base:migration CreateAzurePurchaseOrderOverTime azure_date:references azure_purchase_order:references status:string quantity_dispatched:integer

rails generate second_base:migration CreateAzureInvoiceOverTime azure_date:references azure_invoice:references status:string