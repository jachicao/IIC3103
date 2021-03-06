class AnalyzePurchaseOrderWorker < ApplicationWorker

  def buy(result)
    if result[:purchase_items] != nil
      result[:purchase_items].each do |p|
        self.buy(p)
      end
    end
    if result[:buy] and result[:success]
      product_in_sale = ProductInSale.find_by(id: result[:id])
      product_in_sale.buy_product_async(result[:quantity])
    end
  end

  def perform(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil
      if purchase_order.supplier_id == ENV['GROUP_ID']
        if purchase_order.is_b2c

        else
          my_product_in_sale = purchase_order.product.get_my_product_in_sale
          if my_product_in_sale != nil
            if purchase_order.unit_price >= my_product_in_sale.price
              if DateTime.current <= purchase_order.delivery_date
                product = my_product_in_sale.product
                result = product.analyze_purchase_order(purchase_order.quantity)
                if result[:success]
                  if (DateTime.current + result[:time].to_f.hours) <= purchase_order.delivery_date
                    if result[:buy]
                      buy(result)
                    end
                    purchase_order.accept
                  else
                    purchase_order.reject('Tiempo insuficiente')
                  end
                else
                  purchase_order.reject('Stock insuficiente')
                end
              else
                purchase_order.reject('Tiempo insuficiente')
              end
            else
              purchase_order.reject('Precio incorrecto')
            end
          else
            purchase_order.reject('SKU incorrecto')
          end
        end
      else
        purchase_order.reject('Proveedor incorrecto')
      end
    end
  end
end
