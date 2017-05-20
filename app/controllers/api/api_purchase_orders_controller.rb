class Api::ApiPurchaseOrdersController < Api::ApiController
  before_action :set_purchase_order, only: [:update_accepted, :update_rejected]


  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
    response = GetPurchaseOrderJob.perform_now(params[:po_id])
    case response[:code]
      when 200
        params[:store_reception_id] = params[:id_store_reception]
        @purchase_order = PurchaseOrder.new({ po_id: params[:id], store_reception_id: params[:store_reception_id], payment_method: params[:payment_method], status: 'created' })
        if @purchase_order.save
          render json: @purchase_order
        else
          render json: @purchase_order.errors, status: :unprocessable_entity
        end
      else
        return render :json => { :error => 'Error' }, status: response[:code]
    end
  end

  # PATCH/PUT /purchase_orders/1/accepted
  # PATCH/PUT /purchase_orders/1/accepted.json
  def update_accepted
    if @purchase_order.update(status: 'accepted')
      render json: @purchase_order
    else
      render json: @purchase_order.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /purchase_orders/1/rejected
  # PATCH/PUT /purchase_orders/1/rejected.json
  def update_rejected
    if @purchase_order.update(status: 'rejected')
      render json: @purchase_order
    else
      render json: @purchase_order.errors, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_purchase_order
    @purchase_order = PurchaseOrder.find_by(po_id: params[:po_id])
  end
end
