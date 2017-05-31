class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show]

  def index
    @invoices = Invoice.all
  end

  def show
  end

  def create_bill
    if params[:id].present?
      order = Spree::Order.find(params[:id])
      if order.bill.present?
        bill = order.bill
      else
        cliente = order.email.present? ? order.email : 'unknown'
        monto = order.total.to_i
        bill = Invoice.create_bill(cliente, monto)
      end
      if bill == nil
        redirect_to 'spree/cart', alert: 'Hubo un problema generando la boleta, por favor intente de nuevo'
      else
        url = Invoice.create_url(bill)
        redirect_to url
      end
    end
  end


  private
    def set_invoice
      @invoice = Invoice.find(params[:id])
      @response_server = @invoice.get_server_details
    end
end