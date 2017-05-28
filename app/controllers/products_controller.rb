class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :produce, :post_produce, :purchase_items, :post_purchase_items]
  before_action :set_purchase_items, only: [:purchase_items, :post_purchase_items]

  def post_purchase_items
    @product.purchase_stock(@lote, @quantity, @purchase_items)
    respond_to do |format|
      format.html { redirect_to products_path, notice: 'Productos mandados a comprar' }
      format.json { render json: { :success => true } }
    end
  end

  def purchase_items

  end

  def post_produce
    maximum_time = params[:maximum_time].to_i
    quantity = params[:quantity].to_i

    result = @product.analyze_stock(quantity)

    respond_to do |format|
      if result == nil
        format.html { redirect_to products_path, notice: 'Servidor colapsado' }
        format.json { render json: { :error => 'Servidor colapsado' }, status: :unprocessable_entity }
      elsif result[:maximum_time] <= maximum_time
        format.html { redirect_to controller: 'products', action: 'purchase_items', lote: result[:lote], quantity: result[:quantity], purchase_items: result[:purchase_items] }
        format.json { render json: result[:purchase_items] }
      else
        format.html { redirect_to products_path, notice: 'No se alcanza a cumplir el tiempo' }
        format.json { render json: { :error => 'No se alcanza a cumplir el tiempo' }, status: :unprocessable_entity }
      end
    end
  end

  def produce
    me = Producer.get_me
    @products = []
    me.product_in_sales.each do |product_in_sale|
      @products.push(product_in_sale.product)
    end
  end

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
    @me = Producer.get_me
    @my_products = []
    @me.product_in_sales.each do |product_in_sale|
      @my_products[product_in_sale.product.sku.to_i] = product_in_sale.product
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:sku, :name, :product_type, :unit, :unit_cost, :lote)
    end

    def set_purchase_items
      @lote = params[:lote]
      @quantity = params[:quantity]
      @purchase_items = []
      if params[:purchase_items] != nil
        params[:purchase_items].each do |item|
          @purchase_items.push({ sku: item[:sku], quantity: item[:quantity].to_i, lote: item[:lote].to_i, producer_id: item[:producer_id], produce_time: item[:produce_time].to_f })
        end
      end
    end
end
