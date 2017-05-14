class ProductInSalesController < ApplicationController
  before_action :set_product_in_sale, only: [:show, :edit, :update, :destroy]

  # GET /product_in_sales
  # GET /product_in_sales.json
  def index
    @product_in_sales = ProductInSale.all
  end

  # GET /product_in_sales/1
  # GET /product_in_sales/1.json
  def show
  end

  # GET /product_in_sales/new
  def new
    @product_in_sale = ProductInSale.new
  end

  # GET /product_in_sales/1/edit
  def edit
  end

  # POST /product_in_sales
  # POST /product_in_sales.json
  def create
    @product_in_sale = ProductInSale.new(product_in_sale_params)

    respond_to do |format|
      if @product_in_sale.save
        format.html { redirect_to @product_in_sale, notice: 'Product in sale was successfully created.' }
        format.json { render :show, status: :created, location: @product_in_sale }
      else
        format.html { render :new }
        format.json { render json: @product_in_sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_in_sales/1
  # PATCH/PUT /product_in_sales/1.json
  def update
    respond_to do |format|
      if @product_in_sale.update(product_in_sale_params)
        format.html { redirect_to @product_in_sale, notice: 'Product in sale was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_in_sale }
      else
        format.html { render :edit }
        format.json { render json: @product_in_sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_in_sales/1
  # DELETE /product_in_sales/1.json
  def destroy
    @product_in_sale.destroy
    respond_to do |format|
      format.html { redirect_to product_in_sales_url, notice: 'Product in sale was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_in_sale
      @product_in_sale = ProductInSale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_in_sale_params
      params.require(:product_in_sale).permit(:producer_id, :product_id, :price, :average_time)
    end
end
