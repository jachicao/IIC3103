class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show]

  def index
    @invoices = Invoice.all
  end

  def show

  end

  private
    def set_invoice
      @invoice = Invoice.find(params[:id])
      @response_server = @invoice.get_server_details
    end
end