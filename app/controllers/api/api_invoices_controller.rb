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
        body = response[:body]
        @invoice = Invoice.new(
            _id: body[:_id],
            bank_id: params[:bank_account],
        )
        if @invoice.save
          @invoice.update_properties
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
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end

  def rejected
    if @invoice != nil
      return render :json => { :success => true }
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
          body = response[:body]
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
