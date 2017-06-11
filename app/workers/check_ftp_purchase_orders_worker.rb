require 'net/sftp'
require 'json'

class CheckFtpPurchaseOrdersWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(*args)
    if $checking_ftp_purchase_orders != nil
      return nil
    end
    $checking_ftp_purchase_orders = true
    Net::SFTP.start(ENV['FTP_SERVER_URL'], ENV['FTP_USERNAME'], :password => ENV['FTP_PASSWORD']) do |sftp|
      sftp.dir.entries('/' + ENV['FTP_PURCHASE_ORDERS_FOLDER']).each do |pedido|
        if pedido.name.end_with?('.xml')
          sftp.file.open('/' + ENV['FTP_PURCHASE_ORDERS_FOLDER'] + '/' + pedido.name, 'r') do |file|
            str = ''
            while line = file.gets
              str = str.concat(line)
            end
            parse = JSON.parse(Hash.from_xml(str).to_json, symbolize_names: true)
            puts parse
            po_id = parse[:order][:id]
            purchase_order = PurchaseOrder.find_by(po_id: po_id)
            if purchase_order.nil?
              server = GetPurchaseOrderJob.perform_now(parse[:order][:id])
              if server[:code] == 200
                body = server[:body]
                PurchaseOrder.create(po_id: body[:_id],
                                     client_id: body[:cliente],
                                     supplier_id: body[:proveedor],
                                     delivery_date: DateTime.parse(body[:fechaEntrega]),
                                     unit_price: body[:precioUnitario],
                                     product: Product.find_by(sku: body[:sku]),
                                     quantity: body[:cantidad],
                                     status: body[:estado],
                                     channel: body[:canal]
                )
              end
            end
          end
        end
      end
    end
    $checking_ftp_purchase_orders = nil
  end
end
