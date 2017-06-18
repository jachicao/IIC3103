class CreateInvoiceWorker < ApplicationWorker

  def perform(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil
      server = CreateServerInvoiceJob.perform_now(po_id)
      case server[:code]
        when 200..226

        else
          return {
              :success => false,
              :server => server,
              :group => {},
          }
      end
      body = server[:body]
      group = nil
      if purchase_order.is_b2b
        group = CreateGroupInvoiceJob.perform_now(purchase_order.get_client_group_number, body[:_id])
        puts 'GRUPO  ' + purchase_order.get_client_group_number.to_s
        puts group
        case group[:code]
          when 200..226
          else
            self.cancel_invoice(body[:_id], 'Rejected by group')
            return {
                :success => false,
                :server => server,
                :group => group,
            }
        end
      end

      invoice = Invoice.create(
          _id: body[:_id],
      )
      invoice.update_properties_sync
      return {
          :success => true,
          :server => server,
          :group => group,
      }
    else
      return {
          :success => false,
          :server => {},
          :group => {},
      }
    end
  end
end
