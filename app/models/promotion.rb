class Promotion < ApplicationRecord
  belongs_to :product
  belongs_to :spree_promotion, class_name: 'Spree::Promotion', foreign_key: :spree_id, dependent: :destroy

  after_create :publish_to_social_media
  after_create :create_spree_promotion

  def publish_to_social_media
    if self.publish
      my_product_in_sale = self.product.get_my_product_in_sale
      message = "GRAN PROMOCIÓN: #{self.product.name} a $#{self.price.to_s} desde #{self.starts_at.to_formatted_s(:short)} hasta #{self.expires_at.to_formatted_s(:short)} con el código #{self.code}. #{my_product_in_sale.producer.get_spree_url}"
      image_path = 'app/assets/images/' + self.product.sku + '.png'
      if $twitter != nil
        $twitter.update_with_media(message[0, 140], File.new(Rails.root + image_path))
      end
      if $facebook != nil
        $facebook.put_picture(image_path, 'image/png', { :caption => message }, ENV['FACEBOOK_PAGE_ID'])
      end
    end
  end

  def create_spree_promotion
    my_product_in_sale = self.product.get_my_product_in_sale

    spree_product = nil
    sku = self.product.sku
    Spree::Product.all.each do |p|
      if p.sku == sku
        spree_product = p
      end
    end

    promotion = Spree::Promotion.create!(
        name: self.product.name + ' a $' + self.price.to_s,
        description: 'Codigo: ' + self.code,
        advertise: self.publish,
        code: self.code,
        expires_at: self.expires_at,
        starts_at: self.starts_at,
    )

    rule = Spree::Promotion::Rules::Product.create!(
        promotion: promotion,
    )
    rule.products << spree_product
    rule.save!

    discount = my_product_in_sale.price - self.price

    calculator = Spree::Calculator::FlexiRate.create!(preferences: {
        first_item: discount,
        additional_item: discount,
    })

    adjustment = Spree::Promotion::Actions::CreateItemAdjustments.create!(
        calculator: calculator,
        promotion: promotion,
    )

    promotion.promotion_rules << rule
    promotion.save!

    self.update(spree_promotion: promotion)
  end
end
