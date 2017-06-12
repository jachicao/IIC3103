class UpdateGroupsStockWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(*args)
    Producer.all.each do |producer|
      if producer.is_me
      else
        UpdateGroupStockWorker.perform_async(producer.group_number)
      end
    end
  end
end
