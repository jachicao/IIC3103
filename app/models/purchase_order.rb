class PurchaseOrder < ApplicationRecord
  has_one :invoice

  def self.create_new_purchase_order(producer_id, sku, delivery_date, quantity, unit_price, payment_method)
    recepcion = StoreHouse.get_recepciones
    if recepcion == nil
      return nil
    end
    id_almacen_recepcion = recepcion.first[:_id]

    response_server = CreateServerPurchaseOrderJob.perform_now(
        ENV['GROUP_ID'],
        producer_id,
        sku,
        delivery_date,
        quantity,
        unit_price,
        'b2b',
        'sin notas',
    )
    case response_server[:code]
      when 200

      else
        return nil
    end

    group_number = Producer.where(producer_id: producer_id).first.group_number
    response_group = CreateGroupPurchaseOrderJob.perform_now(
        group_number,
        response_server[:body][:_id],
        payment_method,
        id_almacen_recepcion,
    )
    puts "respuesta grupo" + response_group[:code].to_s
    case response_group[:code]
      when 200 || 201

      else
        #CancelServerPurchaseOrderJob.perform_now(
        #      response_server[:body][:_id],
        #      "Rejected by group",
        #  )
        return false
    end


    @purchase_order = PurchaseOrder.new(po_id: response_server[:body][:_id],
                                        payment_method: payment_method,
                                        store_reception_id: id_almacen_recepcion,
                                        status: response_server[:body][:estado],
                                        own: true,
                                        dispatched: false)
    puts "llego"
    if @purchase_order.save
      return response_server
    else
      return nil
    end
  end
end
