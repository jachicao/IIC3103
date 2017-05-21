class FactoryOrdersController < ApplicationController
  before_action :set_factory_order, only: [:show, :edit, :update, :destroy]

  def submit_purchase_items
    @purchase_items = []
    if params[:purchase_items] != nil
      params[:purchase_items].each do |item|
        @purchase_items.push({ sku: item[:sku], quantity: item[:quantity], producer_id: item[:producer_id], produce_time: item[:produce_time] })
      end
    end

    respond_to do |format|
      if FactoryOrder.purchase_stock(@purchase_items)
        format.html { redirect_to new_factory_order_path, notice: 'Productos mandados a comprar' }
        format.json { render json: { :success => true }, status: :unprocessable_entity }
      else
        format.html { redirect_to new_factory_order_path, notice: 'Falló mandar a producir productos' }
        format.json { render json: { :success => false }, status: :unprocessable_entity }
      end
    end
  end

  def purchase_items
    @purchase_items = []
    if params[:purchase_items] != nil
      params[:purchase_items].each do |item|
        @purchase_items.push({ sku: item[:sku], quantity: item[:quantity], producer_id: item[:producer_id], produce_time: item[:produce_time] })
      end
    end
  end

  def make_products
    product = Product.all.find_by(sku: params[:sku])
    quantity = params[:quantity].to_i
    maximum_time = params[:maximum_time].to_i

    result = FactoryOrder.analyze_stock(product, quantity)

    respond_to do |format|
      if result == nil
        format.html { redirect_to new_factory_order_path, notice: 'Servidor colapsado' }
        format.json { render json: { :error => 'Servidor colapsado' }, status: :unprocessable_entity }
      elsif result[:maximum_time] <= maximum_time
        format.html { redirect_to controller: 'factory_orders', action: 'purchase_items', purchase_items: result[:purchase_items] }
        format.json { render json: result[:purchase_items] }
      else
        format.html { redirect_to new_factory_order_path, notice: 'No se alcanza a cumplir el tiempo' }
        format.json { render json: { :error => 'No se alcanza a cumplir el tiempo' }, status: :unprocessable_entity }
      end
    end
  end

  # GET /factory_orders
  # GET /factory_orders.json
  def index
    @factory_orders = FactoryOrder.all
  end

  # GET /factory_orders/1
  # GET /factory_orders/1.json
  def show
  end

  # GET /factory_orders/new
  def new
    me = Producer.all.find_by(me: true)
    @products = []
    me.product_in_sales.each do |product_in_sale|
      @products.push(product_in_sale.product)
    end
  end

  # GET /factory_orders/1/edit
  def edit
  end

  # POST /factory_orders
  # POST /factory_orders.json
  def create
    @factory_order = FactoryOrder.new(factory_order_params)

    respond_to do |format|
      if @factory_order.save
        format.html { redirect_to @factory_order, notice: 'Factory order was successfully created.' }
        format.json { render :show, status: :created, location: @factory_order }
      else
        format.html { render :new }
        format.json { render json: @factory_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /factory_orders/1
  # PATCH/PUT /factory_orders/1.json
  def update
    respond_to do |format|
      if @factory_order.update(factory_order_params)
        format.html { redirect_to @factory_order, notice: 'Factory order was successfully updated.' }
        format.json { render :show, status: :ok, location: @factory_order }
      else
        format.html { render :edit }
        format.json { render json: @factory_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /factory_orders/1
  # DELETE /factory_orders/1.json
  def destroy
    @factory_order.destroy
    respond_to do |format|
      format.html { redirect_to factory_orders_url, notice: 'Factory order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factory_order
      @factory_order = FactoryOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factory_order_params
      params.require(:factory_order).permit(:fo_id, :sku, :group, :dispatched, :available, :quantity)
    end
end
