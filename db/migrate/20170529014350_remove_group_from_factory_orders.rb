class RemoveGroupFromFactoryOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :factory_orders, :group, :integer
    remove_column :factory_orders, :dispatched, :boolean
    remove_column :factory_orders, :created_at, :datetime
    remove_column :factory_orders, :updated_at, :datetime
  end
end
