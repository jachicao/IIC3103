class FactoryOrdersController < ApplicationController
  before_action :set_factory_order, only: [:show, :edit, :update, :destroy]

  def make_products

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
