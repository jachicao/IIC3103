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
    response = GetPurchaseOrderJob.perform_now(@purchase_order.po_id)
    case response[:code]
      when 200
        @response = response[:body].first
        @product = Product.all.find_by(sku: @response[:sku])
        @cliente = Producer.all.find_by(producer_id: @response[:cliente]).group_number
        @proveedor = Producer.all.find_by(producer_id: @response[:proveedor]).group_number
        respond_to do |format|
          format.html { render :show }
          format.json { render :json => @response }
        end
      else
        return render :json => { :error => response[:body] }, status: response[:code]
    end
  end

  def accept
    po_id = params[:po_id]
    response_server = AcceptServerPurchaseOrderJob.perform_now(po_id)
    case response_server[:code]
      when 200

      else
        return render :json => { :error => response_server[:body] }, status: response[:code]
    end

    group_number = Producer.find_by(producer_id: params[:client_id]).group_number
    response_group = AcceptGroupPurchaseOrderJob.perform_now(group_number, po_id)

    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully accepted.' }
      format.json { head :no_content }
    end
  end

  def reject
    po_id = params[:po_id];
    response_server = RejectServerPurchaseOrderJob.perform_now(po_id, 'causa')
    case response_server[:code]
      when 200

      else
        return render :json => { :error => response_server[:body] }, status: response[:code]
    end
    
    group_number = Producer.find_by(producer_id: params[:client_id]).group_number
    response_group = RejectGroupPurchaseOrderJob.perform_now(group_number, po_id, 'causa')

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
    @products = Product.all
  end

  def created

    result = PurchaseOrder.create_new_purchase_order(
        params[:producers][:id],
        params[:products][:ids],
        Date.new(params[:delivery_date]['(1i)'].to_i, params[:delivery_date]['(2i)'].to_i, params[:delivery_date]['(3i)'].to_i).strftime('%Q'),
        params[:quantity].to_i,
        params[:unit_price].to_i,
        params[:payment_method],
    )
    respond_to do |format|
      if result == nil
        format.html { redirect_to purchase_orders_url, notice: 'Servidor colapsado' }
        format.json { render :json => { :error => 'Servidor colapsado' }, status: 500 }
      else
        format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully created.' }
        format.json { render json: :index }
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
