class UpdateStoreHouseWorker < ApplicationWorker
  sidekiq_options queue: 'critical'

  def perform(store_house_id)
    store_house = StoreHouse.find_by(_id: store_house_id)
    if store_house != nil
      stock_response = self.get_products_with_stock(store_house._id)
      if stock_response != nil
        stock = stock_response[:body]

        hash_stock = Hash.new
        stock.each do |p|
          hash_stock[p[:_id]] = p
        end
        store_house.stocks.each do |s|
          if hash_stock[s.product.sku].nil?
            s.destroy
          end
        end

        stock.each do |p|
          found = nil
          sku = p[:_id]
          quantity = p[:total]
          store_house.stocks.each do |s|
            if s.product.sku == sku
              found = s
            end
          end
          if found.nil?
            product = Product.find_by(sku: sku)
            store_house.stocks.create(
                product: product,
                quantity: quantity
            )
          else
            found.update(quantity: quantity)
          end
        end
      end
    end
  end
end