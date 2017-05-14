# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#Producer
#rails g scaffold Producer producer_id:string:index group_number:integer account:string

producer_1 = Producer.create(producer_id: "5910c0910e42840004f6e680", group_number: 1, account:'')
producer_2 = Producer.create(producer_id: "5910c0910e42840004f6e681", group_number: 2, account:'')
producer_3 = Producer.create(producer_id: "5910c0910e42840004f6e682", group_number: 3, account:'')
producer_4 = Producer.create(producer_id: "5910c0910e42840004f6e683", group_number: 4, account:'')
producer_5 = Producer.create(producer_id: "5910c0910e42840004f6e684", group_number: 5, account:'')
producer_6 = Producer.create(producer_id: "5910c0910e42840004f6e685", group_number: 6, account:'')
producer_7 = Producer.create(producer_id: "5910c0910e42840004f6e686", group_number: 7, account:'')
producer_8 = Producer.create(producer_id: "5910c0910e42840004f6e687", group_number: 8, account:'')

#Products
#rails g scaffold Product sku:string name:string product_type:string unit:string unit_cost:integer lote:integer

product_1	= Product.create(sku: "1"	, name: "Pollo"					, product_type: "raw"		, unit: "Kg"	 , unit_cost: 290 	 , lote: 300)
product_2	= Product.create(sku: "2"	, name: "Huevo"					, product_type: "raw"		, unit: "Un"	 , unit_cost: 102 	 , lote: 150)
product_3	= Product.create(sku: "3"	, name: "Maíz"					, product_type: "raw"		, unit: "Kg"	 , unit_cost: 117 	 , lote: 30)
product_4	= Product.create(sku: "4"	, name: "Aceite de Maravilla"	, product_type: "processed"	, unit: "Lts"	 , unit_cost: 412 	 , lote: 200)
product_5	= Product.create(sku: "5"	, name: "Yogur" 				, product_type: "processed"	, unit: "Lts"	 , unit_cost: 428 	 , lote: 600)
product_6	= Product.create(sku: "6"	, name: "Crema"					, product_type: "processed"	, unit: "Lts"	 , unit_cost: 514 	 , lote: 30)
product_7	= Product.create(sku: "7"	, name: "Leche"					, product_type: "raw"		, unit: "Lts"	 , unit_cost: 290 	 , lote: 1000)
product_8	= Product.create(sku: "8"	, name: "Trigo"					, product_type: "raw"		, unit: "Kg"	 , unit_cost: 252 	 , lote: 100)
product_9	= Product.create(sku: "9"	, name: "Carne"					, product_type: "raw"		, unit: "Kg"	 , unit_cost: 350 	 , lote: 620)
product_10	= Product.create(sku: "10"	, name: "Pan Marraqueta"		, product_type: "processed"	, unit: "Kg"	 , unit_cost: 1084 	 , lote: 900)
product_11	= Product.create(sku: "11"	, name: "Margarina" 			, product_type: "processed"	, unit: "Kg"	 , unit_cost: 247 	 , lote: 900)
product_12	= Product.create(sku: "12"	, name: "Cereal Avena" 			, product_type: "processed"	, unit: "Kg"	 , unit_cost: 624 	 , lote: 400)
product_13	= Product.create(sku: "13"	, name: "Arroz"					, product_type: "raw"		, unit: "Kg"	 , unit_cost: 358 	 , lote: 1000)
product_14	= Product.create(sku: "14"	, name: "Cebada"				, product_type: "raw"		, unit: "Kg"	 , unit_cost: 296 	 , lote: 1750)
product_15	= Product.create(sku: "15"	, name: "Avena"					, product_type: "raw"		, unit: "Kg"	 , unit_cost: 276 	 , lote: 480)
product_16	= Product.create(sku: "16"	, name: "Pasta de Trigo" 		, product_type: "processed"	, unit: "Kg"	 , unit_cost: 612 	 , lote: 1000)
product_17	= Product.create(sku: "17"	, name: "Cereal Arroz" 			, product_type: "processed"	, unit: "Kg"	 , unit_cost: 821 	 , lote: 1000)
product_18	= Product.create(sku: "18"	, name: "Pastel" 				, product_type: "processed"	, unit: "Un"	 , unit_cost: 331 	 , lote: 200)
product_19	= Product.create(sku: "19"	, name: "Sémola"				, product_type: "raw"		, unit: "Kg"	 , unit_cost: 116 	 , lote: 1420)
product_20	= Product.create(sku: "20"	, name: "Cacao"					, product_type: "raw"		, unit: "Kg"	 , unit_cost: 172 	 , lote: 60)
product_22	= Product.create(sku: "22"	, name: "Mantequilla" 			, product_type: "processed"	, unit: "Kg"	 , unit_cost: 336 	 , lote: 400)
product_23	= Product.create(sku: "23"	, name: "Harina"				, product_type: "processed"	, unit: "Kg"	 , unit_cost: 364 	 , lote: 300)
product_25	= Product.create(sku: "25"	, name: "Azúcar"				, product_type: "raw"		, unit: "Kg"	 , unit_cost: 93 	 , lote: 560)
product_26	= Product.create(sku: "26"	, name: "Sal"					, product_type: "raw"		, unit: "Kg"	 , unit_cost: 99 	 , lote: 144)
product_27	= Product.create(sku: "27"	, name: "Levadura"				, product_type: "raw"		, unit: "Kg"	 , unit_cost: 232 	 , lote: 620)
product_34	= Product.create(sku: "34"	, name: "Cerveza" 				, product_type: "processed"	, unit: "Lts"	 , unit_cost: 557 	 , lote: 700)
product_38	= Product.create(sku: "38"	, name: "Semillas Maravilla" 	, product_type: "raw"		, unit: "Kg"	 , unit_cost: 379 	 , lote: 30)
product_39	= Product.create(sku: "39"	, name: "Uva"					, product_type: "raw"		, unit: "Kg"	 , unit_cost: 233 	 , lote: 250)
product_40	= Product.create(sku: "40"	, name: "Queso" 				, product_type: "processed"	, unit: "Kg"	 , unit_cost: 596 	 , lote: 900)
product_41	= Product.create(sku: "41"	, name: "Suero de Leche"		, product_type: "processed"	, unit: "Lts"	 , unit_cost: 256 	 , lote: 200)
product_42	= Product.create(sku: "42"	, name: "Cereal Maíz"			, product_type: "processed"	, unit: "Kg"	 , unit_cost: 812 	 , lote: 200)
product_46	= Product.create(sku: "46"	, name: "Chocolate"				, product_type: "processed"	, unit: "Kg"	 , unit_cost: 424 	 , lote: 800)
product_47	= Product.create(sku: "47"	, name: "Vino" 					, product_type: "processed"	, unit: "Lts"	 , unit_cost: 550 	 , lote: 1000)
product_48	= Product.create(sku: "48"	, name: "Pasta de Sémola" 		, product_type: "processed"	, unit: "Kg"	 , unit_cost: 786 	 , lote: 500)
product_49	= Product.create(sku: "49"	, name: "Leche Descremada"		, product_type: "processed"	, unit: "Lts"	 , unit_cost: 268 	 , lote: 200)
product_50	= Product.create(sku: "50"	, name: "Arroz con Leche"		, product_type: "processed"	, unit: "Kg"	 , unit_cost: 773 	 , lote: 350)
product_51	= Product.create(sku: "51"	, name: "Pan Hallulla"			, product_type: "processed"	, unit: "Kg"	 , unit_cost: 948 	 , lote: 600)
product_52	= Product.create(sku: "52"	, name: "Harina Integral"		, product_type: "processed"	, unit: "Kg"	 , unit_cost: 410 	 , lote: 890)
product_53	= Product.create(sku: "53"	, name: "Pan Integral"			, product_type: "processed"	, unit: "Kg"	 , unit_cost: 934 	 , lote: 620)
product_54	= Product.create(sku: "54"	, name: "Hamburguesas"			, product_type: "processed"	, unit: "Kg"	 , unit_cost: 606 	 , lote: 1800)
product_55	= Product.create(sku: "55"	, name: "Galletas Integrales"	, product_type: "processed"	, unit: "Kg"	 , unit_cost: 925 	 , lote: 950)
product_56	= Product.create(sku: "56"	, name: "Hamburguesas de Pollo"	, product_type: "processed"	, unit: "Kg"	 , unit_cost: 479 	 , lote: 620)



#Recipe
#rails g scaffold Recipe product:references
#class Recipe < ApplicationRecord
#  belongs_to :product
#  has_many :ingredients
#  accepts_nested_attributes_for :ingredients
#end


#Ingredient
#rails g scaffold Ingredient product:references recipe:references quantity:integer
#class Ingredient < ApplicationRecord
#  belongs_to :product
#  belongs_to :recipe
#end

recipe_1 = Recipe.create(product: product_4)
recipe_1.ingredients.create(product: product_38	, quantity: 190)

recipe_2 = Recipe.create(product: product_5)
recipe_2.ingredients.create(product: product_49	, quantity: 228)
recipe_2.ingredients.create(product: product_6	, quantity: 228)
recipe_2.ingredients.create(product: product_41	, quantity: 194)

recipe_3 = Recipe.create(product: product_6)
recipe_3.ingredients.create(product: product_49	, quantity: 100)
recipe_3.ingredients.create(product: product_7	, quantity: 300)

recipe_4 = Recipe.create(product: product_10)
recipe_4.ingredients.create(product: product_23	, quantity: 342)
recipe_4.ingredients.create(product: product_26	, quantity: 309)
recipe_4.ingredients.create(product: product_4	, quantity: 100)
recipe_4.ingredients.create(product: product_27	, quantity: 279)

recipe_5 = Recipe.create(product: product_11)
recipe_5.ingredients.create(product: product_4	, quantity: 828)

recipe_6 = Recipe.create(product: product_12)
recipe_6.ingredients.create(product: product_25	, quantity: 133)
recipe_6.ingredients.create(product: product_20	, quantity: 147)
recipe_6.ingredients.create(product: product_15	, quantity: 113)

recipe_7 = Recipe.create(product: product_16)
recipe_7.ingredients.create(product: product_23	, quantity: 330)
recipe_7.ingredients.create(product: product_26	, quantity: 313)
recipe_7.ingredients.create(product: product_2	, quantity: 383)

recipe_8 = Recipe.create(product: product_17)
recipe_8.ingredients.create(product: product_25	, quantity: 360)
recipe_8.ingredients.create(product: product_20	, quantity: 350)
recipe_8.ingredients.create(product: product_13	, quantity: 290)

recipe_9 = Recipe.create(product: product_18)
recipe_9.ingredients.create(product: product_23	, quantity: 72)
recipe_9.ingredients.create(product: product_2	, quantity: 71)
recipe_9.ingredients.create(product: product_7	, quantity: 67)

recipe_10 = Recipe.create(product: product_22)
recipe_10.ingredients.create(product: product_6	, quantity: 380)

recipe_11 = Recipe.create(product: product_23)
recipe_11.ingredients.create(product: product_8	, quantity: 309)

recipe_12 = Recipe.create(product: product_34)
recipe_12.ingredients.create(product: product_14	, quantity: 333)
recipe_12.ingredients.create(product: product_27	, quantity: 319)

recipe_13 = Recipe.create(product: product_40)
recipe_13.ingredients.create(product: product_7	, quantity: 1000)
recipe_13.ingredients.create(product: product_41	, quantity: 800)

recipe_14 = Recipe.create(product: product_41)
recipe_14.ingredients.create(product: product_7	, quantity: 2000)

recipe_15 = Recipe.create(product: product_42)
recipe_15.ingredients.create(product: product_25	, quantity: 67)
recipe_15.ingredients.create(product: product_20	, quantity: 71)
recipe_15.ingredients.create(product: product_3	, quantity: 69)

recipe_16 = Recipe.create(product: product_46)
recipe_16.ingredients.create(product: product_20	, quantity: 296)
recipe_16.ingredients.create(product: product_25	, quantity: 269)
recipe_16.ingredients.create(product: product_7	, quantity: 251)

recipe_17 = Recipe.create(product: product_47)
recipe_17.ingredients.create(product: product_39	, quantity: 495)
recipe_17.ingredients.create(product: product_27	, quantity: 570)
recipe_17.ingredients.create(product: product_25	, quantity: 1000)

recipe_18 = Recipe.create(product: product_48)
recipe_18.ingredients.create(product: product_19	, quantity: 160)
recipe_18.ingredients.create(product: product_26	, quantity: 172)
recipe_18.ingredients.create(product: product_2	, quantity: 155)

recipe_19 = Recipe.create(product: product_49)
recipe_19.ingredients.create(product: product_7	, quantity: 222)

recipe_20 = Recipe.create(product: product_50)
recipe_20.ingredients.create(product: product_7	, quantity: 200)
recipe_20.ingredients.create(product: product_25	, quantity: 41)
recipe_20.ingredients.create(product: product_13	, quantity: 100)

recipe_21 = Recipe.create(product: product_51)
recipe_21.ingredients.create(product: product_23	, quantity: 800)
recipe_21.ingredients.create(product: product_26	, quantity: 182)
recipe_21.ingredients.create(product: product_22	, quantity: 200)
recipe_21.ingredients.create(product: product_27	, quantity: 279)

recipe_22 = Recipe.create(product: product_52)
recipe_22.ingredients.create(product: product_8	, quantity: 1000)
recipe_22.ingredients.create(product: product_38	, quantity: 20)

recipe_23 = Recipe.create(product: product_53)
recipe_23.ingredients.create(product: product_52	, quantity: 500)
recipe_23.ingredients.create(product: product_26	, quantity: 63)
recipe_23.ingredients.create(product: product_38	, quantity: 250)
recipe_23.ingredients.create(product: product_7	, quantity: 651)
recipe_23.ingredients.create(product: product_23	, quantity: 15)

recipe_24 = Recipe.create(product: product_54)
recipe_24.ingredients.create(product: product_9	, quantity: 2154)
recipe_24.ingredients.create(product: product_26	, quantity: 153)

recipe_25 = Recipe.create(product: product_55)
recipe_25.ingredients.create(product: product_52	, quantity: 1365)
recipe_25.ingredients.create(product: product_20	, quantity: 96)
recipe_25.ingredients.create(product: product_23	, quantity: 20)
recipe_25.ingredients.create(product: product_2	, quantity: 560)

recipe_26 = Recipe.create(product: product_56)
recipe_26.ingredients.create(product: product_1	, quantity: 935)
recipe_26.ingredients.create(product: product_26	, quantity: 65)

#ProductInSale
#rails g scaffold ProductInSale producer:references product:references price:integer average_time:decimal

product_in_sale_1	= ProductInSale.create(product: product_1	, producer: producer_1	, average_time: 2.176, price: 377)
#product_in_sale_2	= ProductInSale.create(product: product_1	, producer: producer_3	, average_time: 3.605)
#product_in_sale_3	= ProductInSale.create(product: product_2	, producer: producer_2	, average_time: 2.551)
#product_in_sale_4	= ProductInSale.create(product: product_2	, producer: producer_4	, average_time: 2.011)
#product_in_sale_5	= ProductInSale.create(product: product_2	, producer: producer_6	, average_time: 2.375)
#product_in_sale_6	= ProductInSale.create(product: product_3	, producer: producer_3	, average_time: 2.172)
#product_in_sale_7	= ProductInSale.create(product: product_3	, producer: producer_5	, average_time: 1.726)
#product_in_sale_8	= ProductInSale.create(product: product_4	, producer: producer_4	, average_time: 2.713)
#product_in_sale_9	= ProductInSale.create(product: product_4	, producer: producer_6	, average_time: 2.615)
#product_in_sale_10	= ProductInSale.create(product: product_4	, producer: producer_8	, average_time: 1.205)
#product_in_sale_11	= ProductInSale.create(product: product_5	, producer: producer_5	, average_time: 3.191)
#product_in_sale_12	= ProductInSale.create(product: product_6	, producer: producer_6	, average_time: 2.916)
#product_in_sale_13	= ProductInSale.create(product: product_6	, producer: producer_8	, average_time: 2.481)
#product_in_sale_14	= ProductInSale.create(product: product_6	, producer: producer_2	, average_time: 2.123)
product_in_sale_15	= ProductInSale.create(product: product_7	, producer: producer_1	, average_time: 1.593, price: 363)
#product_in_sale_16	= ProductInSale.create(product: product_7	, producer: producer_3	, average_time: 2.215)
#product_in_sale_17	= ProductInSale.create(product: product_7	, producer: producer_5	, average_time: 1.441)
#product_in_sale_18	= ProductInSale.create(product: product_7	, producer: producer_7	, average_time: 3.261)
#product_in_sale_19	= ProductInSale.create(product: product_8	, producer: producer_2	, average_time: 1.516)
#product_in_sale_20	= ProductInSale.create(product: product_8	, producer: producer_4	, average_time: 2.531)
#product_in_sale_21	= ProductInSale.create(product: product_8	, producer: producer_6	, average_time: 3.773)
#product_in_sale_22	= ProductInSale.create(product: product_9	, producer: producer_3	, average_time: 1.710)
#product_in_sale_23	= ProductInSale.create(product: product_9	, producer: producer_5	, average_time: 2.846)
#product_in_sale_24	= ProductInSale.create(product: product_10	, producer: producer_4	, average_time: 2.771)
#product_in_sale_25	= ProductInSale.create(product: product_11	, producer: producer_5	, average_time: 3.074)
#product_in_sale_26	= ProductInSale.create(product: product_12	, producer: producer_6	, average_time: 3.623)
#product_in_sale_27	= ProductInSale.create(product: product_13	, producer: producer_7	, average_time: 1.304)
product_in_sale_28	= ProductInSale.create(product: product_13	, producer: producer_1	, average_time: 3.256, price: 394)
#product_in_sale_29	= ProductInSale.create(product: product_13	, producer: producer_3	, average_time: 3.164)
#product_in_sale_30	= ProductInSale.create(product: product_14	, producer: producer_2	, average_time: 1.816)
#product_in_sale_31	= ProductInSale.create(product: product_14	, producer: producer_4	, average_time: 1.220)
#product_in_sale_32	= ProductInSale.create(product: product_15	, producer: producer_3	, average_time: 2.669)
#product_in_sale_33	= ProductInSale.create(product: product_15	, producer: producer_5	, average_time: 1.430)
#product_in_sale_34	= ProductInSale.create(product: product_16	, producer: producer_4	, average_time: 2.493)
#product_in_sale_35	= ProductInSale.create(product: product_17	, producer: producer_5	, average_time: 1.158)
#product_in_sale_36	= ProductInSale.create(product: product_18	, producer: producer_6	, average_time: 2.480)
#product_in_sale_37	= ProductInSale.create(product: product_19	, producer: producer_6	, average_time: 1.285)
#product_in_sale_38	= ProductInSale.create(product: product_19	, producer: producer_8	, average_time: 1.881)
#product_in_sale_39	= ProductInSale.create(product: product_20	, producer: producer_2	, average_time: 3.475)
#product_in_sale_40	= ProductInSale.create(product: product_20	, producer: producer_4	, average_time: 1.955)
#product_in_sale_41	= ProductInSale.create(product: product_20	, producer: producer_6	, average_time: 3.356)
#product_in_sale_42	= ProductInSale.create(product: product_20	, producer: producer_8	, average_time: 2.258)
product_in_sale_43	= ProductInSale.create(product: product_22	, producer: producer_1	, average_time: 1.283, price: 437)
#product_in_sale_44	= ProductInSale.create(product: product_22	, producer: producer_3	, average_time: 2.456)
#product_in_sale_45	= ProductInSale.create(product: product_22	, producer: producer_5	, average_time: 1.832)
#product_in_sale_46	= ProductInSale.create(product: product_23	, producer: producer_6	, average_time: 1.555)
#product_in_sale_47	= ProductInSale.create(product: product_23	, producer: producer_7	, average_time: 1.196)
#product_in_sale_48	= ProductInSale.create(product: product_23	, producer: producer_8	, average_time: 0.910)
product_in_sale_49	= ProductInSale.create(product: product_23	, producer: producer_1	, average_time: 2.912, price: 365)
product_in_sale_50	= ProductInSale.create(product: product_25	, producer: producer_1	, average_time: 0.821, price: 121)
#product_in_sale_51	= ProductInSale.create(product: product_25	, producer: producer_3	, average_time: 3.254)
#product_in_sale_52	= ProductInSale.create(product: product_25	, producer: producer_5	, average_time: 2.785)
#product_in_sale_53	= ProductInSale.create(product: product_25	, producer: producer_7	, average_time: 0.945)
#product_in_sale_54	= ProductInSale.create(product: product_26	, producer: producer_2	, average_time: 2.609)
#product_in_sale_55	= ProductInSale.create(product: product_26	, producer: producer_4	, average_time: 1.242)
#product_in_sale_56	= ProductInSale.create(product: product_26	, producer: producer_6	, average_time: 1.092)
#product_in_sale_57	= ProductInSale.create(product: product_26	, producer: producer_8	, average_time: 3.059)
#product_in_sale_58	= ProductInSale.create(product: product_27	, producer: producer_6	, average_time: 3.209)
#product_in_sale_59	= ProductInSale.create(product: product_27	, producer: producer_7	, average_time: 3.439)
#product_in_sale_60	= ProductInSale.create(product: product_27	, producer: producer_8	, average_time: 1.566)
product_in_sale_61	= ProductInSale.create(product: product_34	, producer: producer_1	, average_time: 1.626, price: 780)
#product_in_sale_62	= ProductInSale.create(product: product_38	, producer: producer_7	, average_time: 3.128)
#product_in_sale_63	= ProductInSale.create(product: product_38	, producer: producer_8	, average_time: 3.462)
product_in_sale_64	= ProductInSale.create(product: product_39	, producer: producer_1	, average_time: 3.159, price: 256)
#product_in_sale_65	= ProductInSale.create(product: product_39	, producer: producer_2	, average_time: 3.331)
#product_in_sale_66	= ProductInSale.create(product: product_40	, producer: producer_2	, average_time: 0.865)
#product_in_sale_67	= ProductInSale.create(product: product_41	, producer: producer_2	, average_time: 1.687)
#product_in_sale_68	= ProductInSale.create(product: product_41	, producer: producer_3	, average_time: 1.460)
#product_in_sale_69	= ProductInSale.create(product: product_41	, producer: producer_7	, average_time: 2.091)
#product_in_sale_70	= ProductInSale.create(product: product_42	, producer: producer_8	, average_time: 2.743)
product_in_sale_71	= ProductInSale.create(product: product_46	, producer: producer_1	, average_time: 1.848, price: 594)
#product_in_sale_72	= ProductInSale.create(product: product_47	, producer: producer_7	, average_time: 1.236)
#product_in_sale_73	= ProductInSale.create(product: product_48	, producer: producer_3	, average_time: 1.665)
product_in_sale_74	= ProductInSale.create(product: product_49	, producer: producer_1	, average_time: 2.046, price: 348)
#product_in_sale_75	= ProductInSale.create(product: product_49	, producer: producer_2	, average_time: 2.368)
#product_in_sale_76	= ProductInSale.create(product: product_49	, producer: producer_3	, average_time: 1.846)
#product_in_sale_77	= ProductInSale.create(product: product_50	, producer: producer_4	, average_time: 2.832)
#product_in_sale_78	= ProductInSale.create(product: product_51	, producer: producer_7	, average_time: 3.061)
#product_in_sale_79	= ProductInSale.create(product: product_52	, producer: producer_3	, average_time: 1.443)
#product_in_sale_80	= ProductInSale.create(product: product_52	, producer: producer_5	, average_time: 1.506)
#product_in_sale_81	= ProductInSale.create(product: product_52	, producer: producer_7	, average_time: 1.897)
#product_in_sale_82	= ProductInSale.create(product: product_53	, producer: producer_8	, average_time: 2.400)
#product_in_sale_83	= ProductInSale.create(product: product_54	, producer: producer_4	, average_time: 0.860)
#product_in_sale_84	= ProductInSale.create(product: product_55	, producer: producer_4	, average_time: 3.283)
#product_in_sale_85	= ProductInSale.create(product: product_56	, producer: producer_5	, average_time: 1.533)