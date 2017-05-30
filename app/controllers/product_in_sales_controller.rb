class ProductInSalesController < ApplicationController

  # GET /product_in_sales
  # GET /product_in_sales.json
  def index
    @product_in_sales = ProductInSale.all
  end
end
