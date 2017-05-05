# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

rails generate scaffold PurchaseOrder orderId:string channel:string supplier:string client:string sku:string quantity:integer dispatchedQuantity:integer unitPrice:integer deadline:timestamp state:string rejectionCause:string cancellationCause:string notes:string billId:string


rails generate scaffold Bill supplier:string client:string grossValue:integer iva:integer totalValue:integer paymentStatus:string pushaseOrderId:string paymentDeadline:datetime rejectionCause:string cancellationCause:string


rails generate scaffold Product sku:string storeHouseId:string cost:decimal name:string

rails generate scaffold StoreHouse usedSpace:integer totalSpace:integer reception:boolean dispatch:boolean external:boolean

rails generate scaffold Transaction originAccount:string destinationAccount:string amount:decimal

rails generate scaffold Balance account:string amount:decimal