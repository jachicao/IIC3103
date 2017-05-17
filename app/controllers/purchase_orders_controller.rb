class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy]

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    @purchase_orders = PurchaseOrder.all
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
    @response = GetPurchaseOrderJob.perform_now(@purchase_order.po_id)
    respond_to do |format|
       format.json { render :json => @response }
       format.html { render "show.html.erb" }
    end
  end

  def accept
    id = params[:id];
    response_server = AcceptServerPurchaseOrderJob.perform_now(id)

    group_number = Producer.where(producer_id: params[:cliente_id]).first.group_number
    response_group = AcceptGroupPurchaseOrderJob.perform_now(group_number, id)

    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully accepted.' }
      format.json { head :no_content }
    end
  end

  def reject
    id = params[:id];
    response_server = RejectServerPurchaseOrderJob.perform_now(id, 'causa')
    
    group_number = Producer.where(producer_id: params[:cliente_id]).first.group_number
    response_group = RejectGroupPurchaseOrderJob.perform_now(group_number, id, 'causa')

    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully rejected.' }
      format.json { head :no_content }
    end
  end

  # GET /purchase_orders/new
  def new
    @products = Product.all
    @purchase_order = PurchaseOrder.new
  end

  # GET /purchase_orders/1/edit
  def edit
  end

  def created
    almacenes = GetStoreHousesJob.perform_now
    if almacenes == nil then
      return { :error => '' }
    end
    id_almacen_recepcion = nil
    almacenes.each do |almacen|
      if almacen['recepcion']
        id_almacen_recepcion = almacen['_id']
        break
      end
    end

    response_server = CreateServerPurchaseOrderJob.perform_now(
        ENV['GROUP_ID'],
        params[:cliente][:id],
        params[:products][:ids],
        Date.new(params[:birthday]["(1i)"].to_i, params[:birthday]["(2i)"].to_i, params[:birthday]["(3i)"].to_i).strftime('%Q'),
        params[:cantidad],
        params[:precio_unitario],
        'b2b',
        'sin notas',
    )

    group_number = Producer.where(producer_id: params[:cliente][:id]).first.group_number
    response_group = CreateGroupPurchaseOrderJob.perform_now(
        group_number,
        response_server['_id'],
        params[:payment_method],
        id_almacen_recepcion,
    )


    @purchase_order = PurchaseOrder.new(po_id: response_server['_id'],
                                        payment_method: params[:payment_method],
                                        store_reception_id: id_almacen_recepcion,
                                        status: response_server['estado'])
    respond_to do |format|
      if @purchase_order.save
        format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully rejected.' }
        format.json { head :no_content }
      end
    end
  end

  # POST /purchase_orders
  # POST /purchase_orders.json
  def create

    @purchase_order = PurchaseOrder.new(purchase_order_params)

    respond_to do |format|
      if @purchase_order.save
        format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully rejected.' }
        format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_products
    @products =  Product.where(id: ProductInSale.where(producer: Producer.where(product_id: params[:product_id])).select('product_id'))
  end

  # PATCH/PUT /purchase_orders/1
  # PATCH/PUT /purchase_orders/1.json
  def update
    respond_to do |format|
      if @purchase_order.update(purchase_order_params)
        format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_order }
      else
        format.html { render :edit }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_orders/1
  # DELETE /purchase_orders/1.json
  def destroy
    @purchase_order.destroy
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_params
    end
end
