require 'sneakers'
require 'sneakers/runner'
require 'json'

class Processor
  include Sneakers::Worker
  from_queue :ofertas
  def work(msg)
    puts 'Promotions received: '+ msg
    message = JSON.parse(msg)
    data = {
        product_id: message[:sku],
        price: message[:precio],
        starts_at: message[:inicio],
        expires_at: message[:fin],
        code: message[:codigo],
        publish: message[:publicar]
    }
    my_products = ProductInSale.select(:product_id).where(producer_id: 1).pluck(:product_id)
    if my_products.include?(message[:sku])
      promo = Promotion.create(data)
      if promo[:publish]
        promo.publish_fb
        promo.publish_twitter
      end
    end
  end
end


opts = {
    :amqp => ENV['AMQP_URL']
}

Sneakers.configure(opts)
r = Sneakers::Runner.new([Processor])
r.run