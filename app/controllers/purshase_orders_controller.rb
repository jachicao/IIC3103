class PurshaseOrdersController < ApplicationController
  before_action :set_purshase_order, only: [:show, :edit, :update, :destroy]

  # GET /purshase_orders
  # GET /purshase_orders.json
  def index
    @purshase_orders = PurshaseOrder.all
  end

  # GET /purshase_orders/1
  # GET /purshase_orders/1.json
  def show
    req_params = { :id => @purshase_order.po_id };
    res = HTTParty.get(ENV['CENTRAL_SERVER_URL'] + '/oc/obtener', :query => req_params, :headers => { content_type: 'application/json', accept: 'application/json' } ).parsed_response;
    format.json { render json: JSON.parse(res.body)}
    format.html { render "show.html.erb"  }
  end

  # GET /purshase_orders/new
  def new
    @purshase_order = PurshaseOrder.new
  end

  # GET /purshase_orders/1/edit
  def edit
  end

  # POST /purshase_orders
  # POST /purshase_orders.json
  def create
    @purshase_order = PurshaseOrder.new(purshase_order_params)

    respond_to do |format|
      if @purshase_order.save
        format.html { redirect_to @purshase_order, notice: 'Purshase order was successfully created.' }
        format.json { render :show, status: :created, location: @purshase_order }
      else
        format.html { render :new }
        format.json { render json: @purshase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purshase_orders/1
  # PATCH/PUT /purshase_orders/1.json
  def update
    respond_to do |format|
      if @purshase_order.update(purshase_order_params)
        format.html { redirect_to @purshase_order, notice: 'Purshase order was successfully updated.' }
        format.json { render :show, status: :ok, location: @purshase_order }
      else
        format.html { render :edit }
        format.json { render json: @purshase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purshase_orders/1
  # DELETE /purshase_orders/1.json
  def destroy
    @purshase_order.destroy
    respond_to do |format|
      format.html { redirect_to purshase_orders_url, notice: 'Purshase order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purshase_order
      @purshase_order = PurshaseOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purshase_order_params
      params.fetch(:purshase_order, {})
    end
end
