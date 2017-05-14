class Api::ProductsController < ActionController::Base
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    res = [];
    ProductInSale.all.each do |v|
      if v.producer.group_number == 1
        res.push({ sku: v.product.sku, name: v.product.name, price: v.price })
      end
    end
    render json: {
      :product => res
    }
  end
end
