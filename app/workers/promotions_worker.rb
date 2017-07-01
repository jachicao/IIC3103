class PromotionsWorker < ApplicationWorker

  def perform(*args)
    $bunny.start
    ch = $bunny.create_channel
    q = ch.queue('ofertas', auto_delete: true)
    delivery_info, metadata, payload = q.pop
    $bunny.stop
    if payload != nil
      load_message(payload)
    end
  end

  def load_message(msg)
    puts 'Promotions received: ' + msg
    begin
      parse = JSON.parse(msg, symbolize_names: true)
      product = Product.find_by(sku: parse[:sku])
      if product.is_produced_by_me
        Promotion.create(
            product: product,
            price: parse[:precio],
            starts_at: Time.at(parse[:inicio] / 1000.0),
            expires_at: Time.at(parse[:fin] / 1000.0),
            code: parse[:codigo],
            publish: parse[:publicar],
        )
      end
    rescue Exception => e
      puts e
    end
  end
end