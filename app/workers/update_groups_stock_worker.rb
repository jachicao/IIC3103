class UpdateGroupsStockWorker
  include Sidekiq::Worker

  def perform(*args)
    Producer.all.each do |producer|
      if producer.is_me
      else
        GetGroupPricesJob.perform_now(producer.group_number)
      end
    end
  end
end
