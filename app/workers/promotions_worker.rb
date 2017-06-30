class PromotionsWorker
  include Sneakers::Worker
  from_queue :ofertas

  def work(msg)
    puts 'Promotions received: ' + msg
    logger.info msg
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
      ack!
    rescue Exception => e
      puts e
    end
  end
end