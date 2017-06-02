# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#Producer
#rails g scaffold Producer producer_id:string:index group_number:integer account:string
#class Producer < ApplicationRecord
#  has_many :product_in_sales
#end

#Ingredient.delete_all
#ProductInSale.delete_all
#Product.delete_all
#Producer.delete_all


if Rails.env.production?
  Producer.create(producer_id: '5910c0910e42840004f6e680', group_number: 1, account:'')
  Producer.create(producer_id: '5910c0910e42840004f6e681', group_number: 2, account:'')
  Producer.create(producer_id: '5910c0910e42840004f6e682', group_number: 3, account:'')
  Producer.create(producer_id: '5910c0910e42840004f6e683', group_number: 4, account:'')
  Producer.create(producer_id: '5910c0910e42840004f6e684', group_number: 5, account:'')
  Producer.create(producer_id: '5910c0910e42840004f6e685', group_number: 6, account:'')
  Producer.create(producer_id: '5910c0910e42840004f6e686', group_number: 7, account:'')
  Producer.create(producer_id: '5910c0910e42840004f6e687', group_number: 8, account:'')
else
  Producer.create(producer_id: '590baa00d6b4ec0004902462', group_number: 1, account:'')
  Producer.create(producer_id: '590baa00d6b4ec0004902463', group_number: 2, account:'')
  Producer.create(producer_id: '590baa00d6b4ec0004902464', group_number: 3, account:'')
  Producer.create(producer_id: '590baa00d6b4ec0004902465', group_number: 4, account:'')
  Producer.create(producer_id: '590baa00d6b4ec0004902466', group_number: 5, account:'')
  Producer.create(producer_id: '590baa00d6b4ec0004902467', group_number: 6, account:'')
  Producer.create(producer_id: '590baa00d6b4ec0004902468', group_number: 7, account:'')
  Producer.create(producer_id: '590baa00d6b4ec0004902469', group_number: 8, account:'')
end

#Product
#rails g scaffold Product sku:string name:string product_type:string unit:string unit_cost:integer lote:integer
#class Product < ApplicationRecord
#  has_many :ingredients
#  has_many :product_in_sales
#end

Product.create(sku: '1'	, name: 'Pollo'					, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 290 	 , lote: 300)
Product.create(sku: '2'	, name: 'Huevo'					, product_type: 'raw'		, unit: 'Un'	 , unit_cost: 102 	 , lote: 150)
Product.create(sku: '3'	, name: 'Maíz'					, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 117 	 , lote: 30)
Product.create(sku: '4'	, name: 'Aceite de Maravilla'	, product_type: 'processed'	, unit: 'Lts'	 , unit_cost: 412 	 , lote: 200)
Product.create(sku: '5'	, name: 'Yogur' 				, product_type: 'processed'	, unit: 'Lts'	 , unit_cost: 428 	 , lote: 600)
Product.create(sku: '6'	, name: 'Crema'					, product_type: 'processed'	, unit: 'Lts'	 , unit_cost: 514 	 , lote: 30)
Product.create(sku: '7'	, name: 'Leche'					, product_type: 'raw'		, unit: 'Lts'	 , unit_cost: 290 	 , lote: 1000)
Product.create(sku: '8'	, name: 'Trigo'					, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 252 	 , lote: 100)
Product.create(sku: '9'	, name: 'Carne'					, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 350 	 , lote: 620)
Product.create(sku: '10'	, name: 'Pan Marraqueta'		, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 1084 	 , lote: 900)
Product.create(sku: '11'	, name: 'Margarina' 			, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 247 	 , lote: 900)
Product.create(sku: '12'	, name: 'Cereal Avena' 			, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 624 	 , lote: 400)
Product.create(sku: '13'	, name: 'Arroz'					, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 358 	 , lote: 1000)
Product.create(sku: '14'	, name: 'Cebada'				, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 296 	 , lote: 1750)
Product.create(sku: '15'	, name: 'Avena'					, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 276 	 , lote: 480)
Product.create(sku: '16'	, name: 'Pasta de Trigo' 		, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 612 	 , lote: 1000)
Product.create(sku: '17'	, name: 'Cereal Arroz' 			, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 821 	 , lote: 1000)
Product.create(sku: '18'	, name: 'Pastel' 				, product_type: 'processed'	, unit: 'Un'	 , unit_cost: 331 	 , lote: 200)
Product.create(sku: '19'	, name: 'Sémola'				, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 116 	 , lote: 1420)
Product.create(sku: '20'	, name: 'Cacao'					, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 172 	 , lote: 60)
Product.create(sku: '22'	, name: 'Mantequilla' 			, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 336 	 , lote: 400)
Product.create(sku: '23'	, name: 'Harina'				, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 364 	 , lote: 300)
Product.create(sku: '25'	, name: 'Azúcar'				, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 93 	 , lote: 560)
Product.create(sku: '26'	, name: 'Sal'					, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 99 	 , lote: 144)
Product.create(sku: '27'	, name: 'Levadura'				, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 232 	 , lote: 620)
Product.create(sku: '34'	, name: 'Cerveza' 				, product_type: 'processed'	, unit: 'Lts'	 , unit_cost: 557 	 , lote: 700)
Product.create(sku: '38'	, name: 'Semillas Maravilla' 	, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 379 	 , lote: 30)
Product.create(sku: '39'	, name: 'Uva'					, product_type: 'raw'		, unit: 'Kg'	 , unit_cost: 233 	 , lote: 250)
Product.create(sku: '40'	, name: 'Queso' 				, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 596 	 , lote: 900)
Product.create(sku: '41'	, name: 'Suero de Leche'		, product_type: 'processed'	, unit: 'Lts'	 , unit_cost: 256 	 , lote: 200)
Product.create(sku: '42'	, name: 'Cereal Maíz'			, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 812 	 , lote: 200)
Product.create(sku: '46'	, name: 'Chocolate'				, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 424 	 , lote: 800)
Product.create(sku: '47'	, name: 'Vino' 					, product_type: 'processed'	, unit: 'Lts'	 , unit_cost: 550 	 , lote: 1000)
Product.create(sku: '48'	, name: 'Pasta de Sémola' 		, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 786 	 , lote: 500)
Product.create(sku: '49'	, name: 'Leche Descremada'		, product_type: 'processed'	, unit: 'Lts'	 , unit_cost: 268 	 , lote: 200)
Product.create(sku: '50'	, name: 'Arroz con Leche'		, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 773 	 , lote: 350)
Product.create(sku: '51'	, name: 'Pan Hallulla'			, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 948 	 , lote: 600)
Product.create(sku: '52'	, name: 'Harina Integral'		, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 410 	 , lote: 890)
Product.create(sku: '53'	, name: 'Pan Integral'			, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 934 	 , lote: 620)
Product.create(sku: '54'	, name: 'Hamburguesas'			, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 606 	 , lote: 1800)
Product.create(sku: '55'	, name: 'Galletas Integrales'	, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 925 	 , lote: 950)
Product.create(sku: '56'	, name: 'Hamburguesas de Pollo'	, product_type: 'processed'	, unit: 'Kg'	 , unit_cost: 479 	 , lote: 620)

#Ingredient
#rails g scaffold Ingredient product:references item_id:bigint quantity:integer
#class Ingredient < ApplicationRecord
#  belongs_to :product
#  belongs_to :item, class_name: 'Product', foreign_key: :item_id
#end

Product.all.find_by(sku: '4').ingredients.create(item: Product.all.find_by(sku: '38')	, quantity: 190)

Product.all.find_by(sku: '5').ingredients.create(item: Product.all.find_by(sku: '49')	, quantity: 228)
Product.all.find_by(sku: '5').ingredients.create(item: Product.all.find_by(sku: '6')	, quantity: 228)
Product.all.find_by(sku: '5').ingredients.create(item: Product.all.find_by(sku: '41')	, quantity: 194)

Product.all.find_by(sku: '6').ingredients.create(item: Product.all.find_by(sku: '49')	, quantity: 100)
Product.all.find_by(sku: '6').ingredients.create(item: Product.all.find_by(sku: '7')	, quantity: 300)

Product.all.find_by(sku: '10').ingredients.create(item: Product.all.find_by(sku: '23')	, quantity: 342)
Product.all.find_by(sku: '10').ingredients.create(item: Product.all.find_by(sku: '26')	, quantity: 309)
Product.all.find_by(sku: '10').ingredients.create(item: Product.all.find_by(sku: '4')	, quantity: 100)
Product.all.find_by(sku: '10').ingredients.create(item: Product.all.find_by(sku: '27')	, quantity: 279)

Product.all.find_by(sku: '11').ingredients.create(item: Product.all.find_by(sku: '4')	, quantity: 828)

Product.all.find_by(sku: '12').ingredients.create(item: Product.all.find_by(sku: '25')	, quantity: 133)
Product.all.find_by(sku: '12').ingredients.create(item: Product.all.find_by(sku: '20')	, quantity: 147)
Product.all.find_by(sku: '12').ingredients.create(item: Product.all.find_by(sku: '15')	, quantity: 113)

Product.all.find_by(sku: '16').ingredients.create(item: Product.all.find_by(sku: '23')	, quantity: 330)
Product.all.find_by(sku: '16').ingredients.create(item: Product.all.find_by(sku: '26')	, quantity: 313)
Product.all.find_by(sku: '16').ingredients.create(item: Product.all.find_by(sku: '2')	, quantity: 383)

Product.all.find_by(sku: '17').ingredients.create(item: Product.all.find_by(sku: '25')	, quantity: 360)
Product.all.find_by(sku: '17').ingredients.create(item: Product.all.find_by(sku: '20')	, quantity: 350)
Product.all.find_by(sku: '17').ingredients.create(item: Product.all.find_by(sku: '13')	, quantity: 290)

Product.all.find_by(sku: '18').ingredients.create(item: Product.all.find_by(sku: '23')	, quantity: 72)
Product.all.find_by(sku: '18').ingredients.create(item: Product.all.find_by(sku: '2')	, quantity: 71)
Product.all.find_by(sku: '18').ingredients.create(item: Product.all.find_by(sku: '7')	, quantity: 67)

Product.all.find_by(sku: '22').ingredients.create(item: Product.all.find_by(sku: '6') 	, quantity: 380)

Product.all.find_by(sku: '23').ingredients.create(item: Product.all.find_by(sku: '8')	, quantity: 309)

Product.all.find_by(sku: '34').ingredients.create(item: Product.all.find_by(sku: '14')	, quantity: 333)
Product.all.find_by(sku: '34').ingredients.create(item: Product.all.find_by(sku: '27')	, quantity: 319)

Product.all.find_by(sku: '40').ingredients.create(item: Product.all.find_by(sku: '7')	, quantity: 1000)
Product.all.find_by(sku: '40').ingredients.create(item: Product.all.find_by(sku: '41')	, quantity: 800)

Product.all.find_by(sku: '41').ingredients.create(item: Product.all.find_by(sku: '7')	, quantity: 2000)

Product.all.find_by(sku: '42').ingredients.create(item: Product.all.find_by(sku: '25')	, quantity: 67)
Product.all.find_by(sku: '42').ingredients.create(item: Product.all.find_by(sku: '20')	, quantity: 71)
Product.all.find_by(sku: '42').ingredients.create(item: Product.all.find_by(sku: '3')	, quantity: 69)

Product.all.find_by(sku: '46').ingredients.create(item: Product.all.find_by(sku: '20')	, quantity: 296)
Product.all.find_by(sku: '46').ingredients.create(item: Product.all.find_by(sku: '25')	, quantity: 269)
Product.all.find_by(sku: '46').ingredients.create(item: Product.all.find_by(sku: '7')	, quantity: 251)

Product.all.find_by(sku: '47').ingredients.create(item: Product.all.find_by(sku: '39')	, quantity: 495)
Product.all.find_by(sku: '47').ingredients.create(item: Product.all.find_by(sku: '27')	, quantity: 570)
Product.all.find_by(sku: '47').ingredients.create(item: Product.all.find_by(sku: '25')	, quantity: 1000)

Product.all.find_by(sku: '48').ingredients.create(item: Product.all.find_by(sku: '19')	, quantity: 160)
Product.all.find_by(sku: '48').ingredients.create(item: Product.all.find_by(sku: '26')	, quantity: 172)
Product.all.find_by(sku: '48').ingredients.create(item: Product.all.find_by(sku: '2')	, quantity: 155)

Product.all.find_by(sku: '49').ingredients.create(item: Product.all.find_by(sku: '7')	, quantity: 222)

Product.all.find_by(sku: '50').ingredients.create(item: Product.all.find_by(sku: '7')	, quantity: 200)
Product.all.find_by(sku: '50').ingredients.create(item: Product.all.find_by(sku: '25')	, quantity: 41)
Product.all.find_by(sku: '50').ingredients.create(item: Product.all.find_by(sku: '13')	, quantity: 100)

Product.all.find_by(sku: '51').ingredients.create(item: Product.all.find_by(sku: '23')	, quantity: 800)
Product.all.find_by(sku: '51').ingredients.create(item: Product.all.find_by(sku: '26')	, quantity: 182)
Product.all.find_by(sku: '51').ingredients.create(item: Product.all.find_by(sku: '22')	, quantity: 200)
Product.all.find_by(sku: '51').ingredients.create(item: Product.all.find_by(sku: '27')	, quantity: 279)

Product.all.find_by(sku: '52').ingredients.create(item: Product.all.find_by(sku: '8')	, quantity: 1000)
Product.all.find_by(sku: '52').ingredients.create(item: Product.all.find_by(sku: '38')	, quantity: 20)

Product.all.find_by(sku: '53').ingredients.create(item: Product.all.find_by(sku: '52')	, quantity: 500)
Product.all.find_by(sku: '53').ingredients.create(item: Product.all.find_by(sku: '26')	, quantity: 63)
Product.all.find_by(sku: '53').ingredients.create(item: Product.all.find_by(sku: '38')	, quantity: 250)
Product.all.find_by(sku: '53').ingredients.create(item: Product.all.find_by(sku: '7')	, quantity: 651)
Product.all.find_by(sku: '53').ingredients.create(item: Product.all.find_by(sku: '23')	, quantity: 15)

Product.all.find_by(sku: '54').ingredients.create(item: Product.all.find_by(sku: '9')	, quantity: 2154)
Product.all.find_by(sku: '54').ingredients.create(item: Product.all.find_by(sku: '26')	, quantity: 153)

Product.all.find_by(sku: '55').ingredients.create(item: Product.all.find_by(sku: '52')	, quantity: 1365)
Product.all.find_by(sku: '55').ingredients.create(item: Product.all.find_by(sku: '20')	, quantity: 96)
Product.all.find_by(sku: '55').ingredients.create(item: Product.all.find_by(sku: '23')	, quantity: 20)
Product.all.find_by(sku: '55').ingredients.create(item: Product.all.find_by(sku: '2')	, quantity: 560)

Product.all.find_by(sku: '56').ingredients.create(item: Product.all.find_by(sku: '1')	, quantity: 935)
Product.all.find_by(sku: '56').ingredients.create(item: Product.all.find_by(sku: '26')	, quantity: 65)

#ProductInSale
#rails g scaffold ProductInSale producer:references product:references price:integer average_time:decimal
#class ProductInSale < ApplicationRecord
#  belongs_to :producer
#  belongs_to :product
#end


ProductInSale.create(product: Product.all.find_by(sku: '1')		, producer: Producer.all.find_by(group_number: 1)	, average_time: 2.176, price: 377)
ProductInSale.create(product: Product.all.find_by(sku: '1')		, producer: Producer.all.find_by(group_number: 3)	, average_time: 3.605)
ProductInSale.create(product: Product.all.find_by(sku: '2')		, producer: Producer.all.find_by(group_number: 2)	, average_time: 2.5)
ProductInSale.create(product: Product.all.find_by(sku: '2')		, producer: Producer.all.find_by(group_number: 4)	, average_time: 2.01)
ProductInSale.create(product: Product.all.find_by(sku: '2')		, producer: Producer.all.find_by(group_number: 6)	, average_time: 2.37)
ProductInSale.create(product: Product.all.find_by(sku: '3')		, producer: Producer.all.find_by(group_number: 3)	, average_time: 2.17)
ProductInSale.create(product: Product.all.find_by(sku: '3')		, producer: Producer.all.find_by(group_number: 5)	, average_time: 1.72)
ProductInSale.create(product: Product.all.find_by(sku: '4')		, producer: Producer.all.find_by(group_number: 4)	, average_time: 2.71)
ProductInSale.create(product: Product.all.find_by(sku: '4')		, producer: Producer.all.find_by(group_number: 6)	, average_time: 2.61)
ProductInSale.create(product: Product.all.find_by(sku: '4')		, producer: Producer.all.find_by(group_number: 8)	, average_time: 1.205)
ProductInSale.create(product: Product.all.find_by(sku: '5')		, producer: Producer.all.find_by(group_number: 5)	, average_time: 3.191)
ProductInSale.create(product: Product.all.find_by(sku: '6')		, producer: Producer.all.find_by(group_number: 6)	, average_time: 2.916)
ProductInSale.create(product: Product.all.find_by(sku: '6')		, producer: Producer.all.find_by(group_number: 8)	, average_time: 2.481)
ProductInSale.create(product: Product.all.find_by(sku: '6')		, producer: Producer.all.find_by(group_number: 2)	, average_time: 2.123)
ProductInSale.create(product: Product.all.find_by(sku: '7')		, producer: Producer.all.find_by(group_number: 1)	, average_time: 1.593, price: 363)
ProductInSale.create(product: Product.all.find_by(sku: '7')		, producer: Producer.all.find_by(group_number: 3)	, average_time: 2.215)
ProductInSale.create(product: Product.all.find_by(sku: '7')		, producer: Producer.all.find_by(group_number: 5)	, average_time: 1.441)
ProductInSale.create(product: Product.all.find_by(sku: '7')		, producer: Producer.all.find_by(group_number: 7)	, average_time: 3.261)
ProductInSale.create(product: Product.all.find_by(sku: '8')		, producer: Producer.all.find_by(group_number: 2)	, average_time: 1.516)
ProductInSale.create(product: Product.all.find_by(sku: '8')		, producer: Producer.all.find_by(group_number: 4)	, average_time: 2.531)
ProductInSale.create(product: Product.all.find_by(sku: '8')		, producer: Producer.all.find_by(group_number: 6)	, average_time: 3.773)
ProductInSale.create(product: Product.all.find_by(sku: '9')		, producer: Producer.all.find_by(group_number: 3)	, average_time: 1.710)
ProductInSale.create(product: Product.all.find_by(sku: '9')		, producer: Producer.all.find_by(group_number: 5)	, average_time: 2.846)
ProductInSale.create(product: Product.all.find_by(sku: '10')	, producer: Producer.all.find_by(group_number: 4)	, average_time: 2.771)
ProductInSale.create(product: Product.all.find_by(sku: '11')	, producer: Producer.all.find_by(group_number: 5)	, average_time: 3.074)
ProductInSale.create(product: Product.all.find_by(sku: '12')	, producer: Producer.all.find_by(group_number: 6)	, average_time: 3.623)
ProductInSale.create(product: Product.all.find_by(sku: '13')	, producer: Producer.all.find_by(group_number: 7)	, average_time: 1.304)
ProductInSale.create(product: Product.all.find_by(sku: '13')	, producer: Producer.all.find_by(group_number: 1)	, average_time: 3.256, price: 394)
ProductInSale.create(product: Product.all.find_by(sku: '13')	, producer: Producer.all.find_by(group_number: 3)	, average_time: 3.164)
ProductInSale.create(product: Product.all.find_by(sku: '14')	, producer: Producer.all.find_by(group_number: 2)	, average_time: 1.816)
ProductInSale.create(product: Product.all.find_by(sku: '14')	, producer: Producer.all.find_by(group_number: 4)	, average_time: 1.220)
ProductInSale.create(product: Product.all.find_by(sku: '15')	, producer: Producer.all.find_by(group_number: 3)	, average_time: 2.669)
ProductInSale.create(product: Product.all.find_by(sku: '15')	, producer: Producer.all.find_by(group_number: 5)	, average_time: 1.430)
ProductInSale.create(product: Product.all.find_by(sku: '16')	, producer: Producer.all.find_by(group_number: 4)	, average_time: 2.493)
ProductInSale.create(product: Product.all.find_by(sku: '17')	, producer: Producer.all.find_by(group_number: 5)	, average_time: 1.158)
ProductInSale.create(product: Product.all.find_by(sku: '18')	, producer: Producer.all.find_by(group_number: 6)	, average_time: 2.480)
ProductInSale.create(product: Product.all.find_by(sku: '19')	, producer: Producer.all.find_by(group_number: 6)	, average_time: 1.285)
ProductInSale.create(product: Product.all.find_by(sku: '19')	, producer: Producer.all.find_by(group_number: 8)	, average_time: 1.881)
ProductInSale.create(product: Product.all.find_by(sku: '20')	, producer: Producer.all.find_by(group_number: 2)	, average_time: 3.475)
ProductInSale.create(product: Product.all.find_by(sku: '20')	, producer: Producer.all.find_by(group_number: 4)	, average_time: 1.955)
ProductInSale.create(product: Product.all.find_by(sku: '20')	, producer: Producer.all.find_by(group_number: 6)	, average_time: 3.356)
ProductInSale.create(product: Product.all.find_by(sku: '20')	, producer: Producer.all.find_by(group_number: 8)	, average_time: 2.258)
ProductInSale.create(product: Product.all.find_by(sku: '22')	, producer: Producer.all.find_by(group_number: 1)	, average_time: 1.283, price: 437)
ProductInSale.create(product: Product.all.find_by(sku: '22')	, producer: Producer.all.find_by(group_number: 3)	, average_time: 2.456)
ProductInSale.create(product: Product.all.find_by(sku: '22')	, producer: Producer.all.find_by(group_number: 5)	, average_time: 1.832)
ProductInSale.create(product: Product.all.find_by(sku: '23')	, producer: Producer.all.find_by(group_number: 6)	, average_time: 1.555)
ProductInSale.create(product: Product.all.find_by(sku: '23')	, producer: Producer.all.find_by(group_number: 7)	, average_time: 1.196)
ProductInSale.create(product: Product.all.find_by(sku: '23')	, producer: Producer.all.find_by(group_number: 8)	, average_time: 0.910)
ProductInSale.create(product: Product.all.find_by(sku: '23')	, producer: Producer.all.find_by(group_number: 1)	, average_time: 2.912, price: 365)
ProductInSale.create(product: Product.all.find_by(sku: '25')	, producer: Producer.all.find_by(group_number: 1)	, average_time: 0.821, price: 121)
ProductInSale.create(product: Product.all.find_by(sku: '25')	, producer: Producer.all.find_by(group_number: 3)	, average_time: 3.254)
ProductInSale.create(product: Product.all.find_by(sku: '25')	, producer: Producer.all.find_by(group_number: 5)	, average_time: 2.785)
ProductInSale.create(product: Product.all.find_by(sku: '25')	, producer: Producer.all.find_by(group_number: 7)	, average_time: 0.945)
ProductInSale.create(product: Product.all.find_by(sku: '26')	, producer: Producer.all.find_by(group_number: 2)	, average_time: 2.609)
ProductInSale.create(product: Product.all.find_by(sku: '26')	, producer: Producer.all.find_by(group_number: 4)	, average_time: 1.242)
ProductInSale.create(product: Product.all.find_by(sku: '26')	, producer: Producer.all.find_by(group_number: 6)	, average_time: 1.092)
ProductInSale.create(product: Product.all.find_by(sku: '26')	, producer: Producer.all.find_by(group_number: 8)	, average_time: 3.059)
ProductInSale.create(product: Product.all.find_by(sku: '27')	, producer: Producer.all.find_by(group_number: 6)	, average_time: 3.209)
ProductInSale.create(product: Product.all.find_by(sku: '27')	, producer: Producer.all.find_by(group_number: 7)	, average_time: 3.439)
ProductInSale.create(product: Product.all.find_by(sku: '27')	, producer: Producer.all.find_by(group_number: 8)	, average_time: 1.566)
ProductInSale.create(product: Product.all.find_by(sku: '34')	, producer: Producer.all.find_by(group_number: 1)	, average_time: 1.626, price: 780)
ProductInSale.create(product: Product.all.find_by(sku: '38')	, producer: Producer.all.find_by(group_number: 7)	, average_time: 3.128)
ProductInSale.create(product: Product.all.find_by(sku: '38')	, producer: Producer.all.find_by(group_number: 8)	, average_time: 3.462)
ProductInSale.create(product: Product.all.find_by(sku: '39')	, producer: Producer.all.find_by(group_number: 1)	, average_time: 3.159, price: 256)
ProductInSale.create(product: Product.all.find_by(sku: '39')	, producer: Producer.all.find_by(group_number: 2)	, average_time: 3.331)
ProductInSale.create(product: Product.all.find_by(sku: '40')	, producer: Producer.all.find_by(group_number: 2)	, average_time: 0.865)
ProductInSale.create(product: Product.all.find_by(sku: '41')	, producer: Producer.all.find_by(group_number: 2)	, average_time: 1.687)
ProductInSale.create(product: Product.all.find_by(sku: '41')	, producer: Producer.all.find_by(group_number: 3)	, average_time: 1.460)
ProductInSale.create(product: Product.all.find_by(sku: '41')	, producer: Producer.all.find_by(group_number: 7)	, average_time: 2.091)
ProductInSale.create(product: Product.all.find_by(sku: '42')	, producer: Producer.all.find_by(group_number: 8)	, average_time: 2.743)
ProductInSale.create(product: Product.all.find_by(sku: '46')	, producer: Producer.all.find_by(group_number: 1)	, average_time: 1.848, price: 594)
ProductInSale.create(product: Product.all.find_by(sku: '47')	, producer: Producer.all.find_by(group_number: 7)	, average_time: 1.236)
ProductInSale.create(product: Product.all.find_by(sku: '48')	, producer: Producer.all.find_by(group_number: 3)	, average_time: 1.665)
ProductInSale.create(product: Product.all.find_by(sku: '49')	, producer: Producer.all.find_by(group_number: 1)	, average_time: 2.046, price: 348)
ProductInSale.create(product: Product.all.find_by(sku: '49')	, producer: Producer.all.find_by(group_number: 2)	, average_time: 2.368)
ProductInSale.create(product: Product.all.find_by(sku: '49')	, producer: Producer.all.find_by(group_number: 3)	, average_time: 1.846)
ProductInSale.create(product: Product.all.find_by(sku: '50')	, producer: Producer.all.find_by(group_number: 4)	, average_time: 2.832)
ProductInSale.create(product: Product.all.find_by(sku: '51')	, producer: Producer.all.find_by(group_number: 7)	, average_time: 3.061)
ProductInSale.create(product: Product.all.find_by(sku: '52')	, producer: Producer.all.find_by(group_number: 3)	, average_time: 1.443)
ProductInSale.create(product: Product.all.find_by(sku: '52')	, producer: Producer.all.find_by(group_number: 5)	, average_time: 1.506)
ProductInSale.create(product: Product.all.find_by(sku: '52')	, producer: Producer.all.find_by(group_number: 7)	, average_time: 1.897)
ProductInSale.create(product: Product.all.find_by(sku: '53')	, producer: Producer.all.find_by(group_number: 8)	, average_time: 2.400)
ProductInSale.create(product: Product.all.find_by(sku: '54')	, producer: Producer.all.find_by(group_number: 4)	, average_time: 0.860)
ProductInSale.create(product: Product.all.find_by(sku: '55')	, producer: Producer.all.find_by(group_number: 4)	, average_time: 3.283)
ProductInSale.create(product: Product.all.find_by(sku: '56')	, producer: Producer.all.find_by(group_number: 5)	, average_time: 1.533)


Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)




pollo = Spree::Product.create(name:'Pollo', description:'Desplumado', shipping_category_id: 1, sku: 1, price: 377, cost_price: 290, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Pollo.png'), :viewable => pollo.master)
leche = Spree::Product.create( name: 'Leche', description:'Leche Entera', shipping_category_id: 1, sku: 7, price: 363, cost_price: 290, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Leche.png'), :viewable => leche.master)
arroz = Spree::Product.create( name: 'Arroz', description:'Rico y Natural', shipping_category_id: 1, sku: 13, price: 394, cost_price: 358, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Arroz.png'), :viewable => arroz.master)
mantequilla = Spree::Product.create( name: 'Mantequilla', description:'No es Margarina', shipping_category_id: 1, sku: 22, price: 437, cost_price: 336, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Mantequilla.png'), :viewable => mantequilla.master)
harina = Spree::Product.create( name: 'Harina', description:'Con Polvos de Hornear', shipping_category_id: 1, sku: 23, price: 400, cost_price: 364, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Harina.png'), :viewable => harina.master)
azucar = Spree::Product.create( name: 'Azúcar', description:'Dulce y no light', shipping_category_id: 1, sku: 25, price: 121, cost_price: 93, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Azucar.png'), :viewable => azucar.master)
cerveza = Spree::Product.create( name: 'Cerveza', description:'Con Polvos de Hornear', shipping_category_id: 1, sku: 34, price: 780, cost_price: 557, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Cerveza.png'), :viewable => cerveza.master)
uva = Spree::Product.create( name: 'Uva', description:'Con Polvos de Hornear', shipping_category_id: 1, sku: 39, price: 256, cost_price: 233, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Uva.png'), :viewable => uva.master)
chocolate = Spree::Product.create( name: 'Chocolate', description:'Con Polvos de Hornear', shipping_category_id: 1, sku: 46, price: 594, cost_price: 424, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Chocolate.png'), :viewable =>chocolate.master)
descremada = Spree::Product.create( name: 'Leche Descremada', description:'Con Polvos de Hornear', shipping_category_id: 1, sku: 49, price: 348, cost_price: 268, available_on: DateTime.now)
Spree::Image.create(:attachment => File.open(Rails.root + 'app/assets/images/Leche_descremada.png'), :viewable => descremada.master)
