require 'net/sftp'
require 'json'

class CheckFtpPurchaseOrdersWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(*args)
    if ENV['DOCKER_RUNNING'] != nil
      Net::SFTP.start(ENV['FTP_SERVER_URL'], ENV['FTP_USERNAME'], :password => ENV['FTP_PASSWORD']) do |sftp|
        sftp.dir.entries('/' + ENV['FTP_PURCHASE_ORDERS_FOLDER']).each do |pedido|
          if pedido.name.end_with?('.xml')
            file_path = '/' + ENV['FTP_PURCHASE_ORDERS_FOLDER'] + '/' + pedido.name
            sftp.file.open(file_path, 'r') do |file|
              str = ''
              while line = file.gets
                str.concat(line)
              end
              parse = JSON.parse(Hash.from_xml(str).to_json, symbolize_names: true)
              po_id = parse[:order][:id]
              purchase_order = PurchaseOrder.find_by(po_id: po_id)
              if purchase_order.nil?
                server = self.get_purchase_order(po_id)
                if server[:code] == 200
                  body = server[:body]
                  po = PurchaseOrder.create(po_id: body[:_id])
                  po.update_properties
                end
              end
            end
            if ENV['DOCKER_RUNNING'] != nil
              #sftp.remove(file_path)
            end
          end
        end
      end
    end
  end
end
