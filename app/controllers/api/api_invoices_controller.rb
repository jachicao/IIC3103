class Api::ApiInvoicesController < Api::ApiController
  before_action :set_invoice, only: [:accepted, :rejected, :paid, :delivered]

  def create
    if params[:bank_account].nil?
      return render :json => { :success => false, :error => 'Falta bank_account' }, status: :bad_request
    end

    set_invoice

    if @invoice != nil
      return render json: { :success => true }
    end

    response = Invoice.get_server_details(params[:invoice_id])
    case response[:code]
      when 200
        body = response[:body].first
        @invoice = Invoice.new(
            _id: body[:_id],
            supplier_id: body[:proveedor],
            client_id: body[:cliente],
            amount: body[:total],
            po_id: body[:oc],
            bank_id: params[:bank_account],
        )
        if @invoice.save
          AnalyzeInvoiceWorker.perform_async(body[:_id])
          return render json: { :success => true }
        else
          return render json: { :success => false, :error => @invoice.errors } , status: :unprocessable_entity
        end
    end
    return render :json => { :success => false, :error => response[:body] }, status: response[:code]
  end

  def accepted
    if @invoice != nil
      return render :json => { :success => true }
=begin
      response = Invoice.get_server_details(params[:invoice_id])
      case response[:code]
        when 200
          body = response[:body].first
          case body[:estado]
            when 'pendiente'
              return render :json => { :success => true }
          end
          return render :json => { :success => false, :error => 'Estado de factura no es \'pendiente\'' }, status: :bad_request
      end
      return render :json => { :success => false, :error => response[:body] }, status: response[:code]
=end
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end

  def rejected
=begin
    if params[:cause].nil?
      return render :json => { :success => false, :error => 'Falta cause' }, status: :bad_request
    end
=end
    if @invoice != nil
      return render :json => { :success => true }
=begin
      response = Invoice.get_server_details(params[:invoice_id])
      case response[:code]
        when 200
          body = response[:body].first
          case body[:estado]
            when 'pendiente'
              return render :json => { :success => true }
          end
          return render :json => { :success => false, :error => 'Estado de factura no es \'pendiente\'' }, status: :bad_request
      end
      return render :json => { :success => false, :error => response[:body] }, status: response[:code]
=end
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end

  def paid
=begin
    if params[:id_transaction].nil?
      return render :json => { :success => false, :error => 'Falta id_transaction' }, status: :bad_request
    end
=end
    if @invoice != nil
      return render :json => { :success => true }
=begin
      response = Invoice.get_server_details(params[:invoice_id])
      case response[:code]
        when 200
          body = response[:body].first
          case body[:estado]
            when 'pagado'
              transaction = Bank.get_transaction(params[:id_transaction])
              case transaction[:code]
                when 200
                  if transaction[:body][:monto] >= body[:total]
                    return render :json => { :success => true }
                  else
                    return render :json => { :success => false, :error => 'Monto es menor a orden de compra' }, status: :bad_request
                  end
              end
              return render :json => { :success => false, :error => 'Transacción no existe' }, status: :bad_request
          end
          return render :json => { :success => false, :error => 'Estado de factura no es \'pagado\'' }, status: :bad_request
      end
      return render :json => { :success => false, :error => response[:body] }, status: response[:code]
=end
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end

  def delivered
    if @invoice != nil
      return render :json => { :success => true }
=begin
        response = PurchaseOrder.get_server_details(@invoice.po_id)
        case response[:code]
          when 200
            body = response[:body].first
            if body[:cantidadDespachada] >= body[:cantidad]
              return render :json => { :success => true }
            else
              return render :json => { :success => false, :error => 'Falta cantidad por despachar' }
            end
        end
        return render :json => { :success => false, :error => response[:body] }, status: response[:code]
=end
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find_by(_id: params[:invoice_id])
    end
end
