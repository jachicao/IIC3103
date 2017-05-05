class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /products
  def index
    if params[:token].present?
      render json: '{"products": [{"id": 1, "sku": "atf1233", "name": "Shovel", "price": 3000, "stock": 7},{"id": 2, "sku": "SCS1343", "name": "Bucket", "price": 2000, "stock": 2},{"id": 3, "sku": "att1233", "name": "T-Shirt", "price": 9000, "stock": 8}]}', status: 200
    else
      render json: {"error": "Token needed" }, status: 403
    end
    @products = Product.all
  end

  # GET /products/1
  def show
    render json: @product
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:sku, :storeHouseId, :cost)
    end
end
