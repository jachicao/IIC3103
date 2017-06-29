class Promotion < ApplicationRecord
  belongs_to :product
  belongs_to :spree_promotion, class_name: 'Spree::Promotion', dependent: :destroy


  def publish_fb
    page = Koala::Facebook::API.new(ENV['FB_PAGE_TOKEN'])
    message = get_message
    picture = get_picture
    page.put_connections(ENV['FB_PAGE_ID'], 'feed', :message => message, :picture => picture, :link => picture)
  end

  def publish_twitter
    client = Twitter::Client.new do |config|
      config.consumer_key        = 'Fp1qeG81KBkFvajTwF7CYSxPH'
      config.consumer_secret     = 'I2DVFtyX2R7NHearlDCmc62gukemyOUeTGVxqyQ4Iak0JGyd9n'
      config.access_token        = '880216663676919808-xO8Bf38761m0Sw9mHwiZLciQL3BiId5'
      config.access_token_secret = 'hthHQ55rMyCgkj7w1xlESdvqsMGirYZcueJ8kvnRjt8HW'
    end
    puts 'twitteando'
    answer = client.update_with_media(get_message, File.new(get_picture_twitter))
    puts answer
  end

  def get_message
    product_name = Product.select(:name).where(sku: self[:product_id]).pluck(:name)
    message = "GRAN PROMOCION: #{product_name[0]}  a $#{self[:price]} desde #{self[:starts_at]} hasta #{self[:expires_at]} con el código #{self[:code]}"
    return message
  end

  def get_picture_twitter
    return Rails.root.join('app', 'assets','images',"#{self[:product_id]}.png")
  end

  def get_picture
    case self[:product_id]
      when 1
        return 'http://comeronocomer.es/sites/default/files/styles/colorbox_grande/public/fotos/pollo.jpeg?itok=GMmJlR8z'
      when 7
        return 'http://cdn2.actitudfem.com/media/files/styles/large/public/images/2014/12/notaleche.jpg'
      when 13
        return 'http://www.curiosfera.com/wp-content/uploads/2016/08/Qué-es-el-arroz.jpg'
      when 22
        return 'https://churreriaestrella.files.wordpress.com/2013/04/image.jpg'
      when 23
        return 'http://www.sualba.com/wp-content/uploads/2015/09/harinas.jpg'
      when 25
        return 'http://contenido.com.mx/revista/wp-content/uploads/2017/04/la-moda-de-pasar-un-mes-sin-tomar-azucar-que-le-pasa-a-la-gente-que-intenta-hacerlo.jpg'
      when 34
        return 'http://cdn2.salud180.com/sites/default/files/styles/medium/public/field/image/2012/09/cerveza_final.jpg'
      when 39
        return 'https://mejorconsalud.com/wp-content/uploads/2014/02/uvas-ROJAS.jpg'
      when 46
        return 'http://www.stopenlinea.com.ar/PcAction/avin/chocolate.jpeg'
      when 49
        return 'http://www.andreu-chile.com/image/cache/data/reposteria/leche%20descremada-500x500.jpg'
    end
  end

end
