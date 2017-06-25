class SpreeOrdersController < ApplicationController
  before_action :set_spree_order, only: [:create_bill]

  def create_bill
    cliente = @spree_order.email.present? ? @spree_order.email : 'unknown'
    monto = @spree_order.total.to_i
    response = Invoice.create_bill(cliente, monto)
    bill_id = response[:body][:_id]
    bill = Invoice.find_by(_id: bill_id)
    @spree_order.line_items.each do |line_item|
      BillItem.create(product: Product.find_by(sku: line_item.sku), invoice: bill, quantity: line_item.quantity, unit_price: line_item.price)
    end
    redirect_to bill.get_bill_url
  end

  private
    def set_spree_order
      @spree_order = Spree::Order.find(params[:id])
    end
end