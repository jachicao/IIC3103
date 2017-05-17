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
    @responce = HTTParty.get(ENV['CENTRAL_SERVER_URL'] + '/oc/obtener/' + @purchase_order.po_id, :headers => { content_type: 'application/json', accept: 'application/json' } ).parsed_response;
    puts @responce
    respond_to do |format|
       format.json { render :json => @responce }
       format.html { render "show.html.erb" }
    end
  end

  def accept
    req_params = { :_id => params[:id]};
    responce_server = HTTParty.post(ENV['CENTRAL_SERVER_URL'] + '/oc/recepcionar/' + params[:id], :params => req_params, :headers => { content_type: 'application/json', accept: 'application/json' } );
    groupNumber = Producer.where(producer_id: params[:cliente_id]).first.group_number.to_s
    if ENV["RAILS_ENV"] == "development"
      responce_cliente = HTTParty.patch('http://dev.integra17-'+ groupNumber + '.ing.puc.cl/api/purchase_orders/' + params[:id] + '/accepted', :headers => { content_type: 'application/json', accept: 'application/json' } );
    else
      responce_cliente = HTTParty.patch('http://integra17-'+ groupNumber + '.ing.puc.cl/api/purchase_orders/' + params[:id] + '/accepted', :headers => { content_type: 'application/json', accept: 'application/json' } );
    end
    puts responce_server.code
    puts responce_cliente.code
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully accepted.' }
      format.json { head :no_content }
    end
  end

  def reject
    HTTParty.post(ENV['CENTRAL_SERVER_URL'] + '/oc/rechazar/' + params[:id], :body => {_id: params[:id], rechazo: "algo"}, :headers => { content_type: 'application/json', accept: 'application/json' } );
    groupNumber = Producer.where(producer_id: params[:cliente_id]).first.group_number.to_s
    if ENV["RAILS_ENV"] == "development"
      responce_cliente = HTTParty.patch('http://dev.integra17-'+ groupNumber + '.ing.puc.cl/api/purchase_orders/' + params[:id] + '/reject', :headers => { content_type: 'application/json', accept: 'application/json' } );
    else
      responce_cliente = HTTParty.patch('http://integra17-'+ groupNumber + '.ing.puc.cl/api/purchase_orders/' + params[:id] + '/reject', :headers => { content_type: 'application/json', accept: 'application/json' } );
    end
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
    req_params = {
      }
    auth_params = {
      }
    server_body = {
      cliente: ENV['GROUP_ID'],
      proveedor: params[:cliente][:id],
      sku: params[:products][:ids],
      fechaEntrega:  Date.new(params[:birthday]["(1i)"].to_i, params[:birthday]["(2i)"].to_i, params[:birthday]["(3i)"].to_i).strftime('%Q'),
      cantidad: params[:cantidad],
      precioUnitario: params[:precio_unitario],
      canal: "b2b",
      notas: "sin"
    }
    puts server_body
    #recepcion_cache = $redis.get("almacen_recepcion");
    #if recepcion_cache.nil?
    almacen_recepcion = nil
      response = HTTParty.get(ENV['CENTRAL_SERVER_URL'] + '/bodega/almacenes/', :body => server_body, :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", auth_params) } );
      body = JSON.parse(response.body)
      body.each do |almacen|
        if almacen["recepcion"] == true
          #$redis.set("almacen_recepcion", almacen.to_json);
          almacen_recepcion = almacen
          break;
        end
      end
    #end
    #almacen_recepcion = JSON.load(recepcion_cache);
    client_body = {
    payment_method: params[:payment_method],
    id_store_reception: almacen_recepcion["_id"],
    }
    server_response = HTTParty.put(ENV['CENTRAL_SERVER_URL'] + '/oc/crear/', :body => server_body, :headers => { content_type: 'application/json', accept: 'application/json'} );
    puts client_body.to_json
    server_response_body = server_response.parsed_response
    groupNumber = Producer.where(producer_id: params[:cliente][:id]).first.group_number.to_s
    puts 'http://dev.integra17-'+ groupNumber +'.ing.puc.cl/purchase_orders/' + server_response_body["_id"]
    puts client_body
    if ENV["RAILS_ENV"] == "development"
      puts "development"
      client_responce = HTTParty.put('http://dev.integra17-'+ groupNumber +'.ing.puc.cl/purchase_orders/' + server_response_body["_id"], :body => client_body.to_json , :headers => { content_type: 'application/json', "Authorization" => ENV["GROUP_ID"] } );
    else
      client_responce = HTTParty.put('http://integra17-'+ groupNumber +'.ing.puc.cl/api/purchase_orders/' + server_response_body["_id"], :body => client_body.to_json, :headers => { content_type: 'application/json', "Authorization" => ENV["GROUP_ID"]} );
    end
    puts client_responce.code
    puts client_responce.body
    @purchase_order = PurchaseOrder.new(po_id: server_response_body["_id"],
                                        payment_method: params[:payment_method],
                                        store_reception_id: almacen_recepcion[:_id],
                                        status: server_response_body["estado"])
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
