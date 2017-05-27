class AddMeToProducers < ActiveRecord::Migration[5.0]
  def change
    add_column :producers, :me, :boolean, default: false
  end
end
