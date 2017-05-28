class PurchasedProduct < ApplicationRecord
  belongs_to :product
  belongs_to :producer
  belongs_to :pending_product

  def send_order
    if producer.group_number == ENV['GROUP_NUMBER'].to_i
      BuyFactoryProductsJob.perform_later(product.sku, quantity, product.unit_cost)
      self.order_sent = true
    else
      result = PurchaseOrder.create_new_purchase_order(
          producer.producer_id,
          product.sku,
          (Time.now + produce_time.to_f.hours).to_i * 1000,
          quantity,
          product.unit_cost, #TODO: Completar esto
          'contra_despacho' #TODO: Completar esto
      )
      if result != nil
        self.po_id = result[:body][:_id]
      end
      self.order_sent = true
    end
    save
  end
end
