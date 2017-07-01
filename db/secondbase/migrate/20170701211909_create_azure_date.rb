class CreateAzureDate < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_dates do |t|
      t.datetime :date
      t.string :description
      t.integer :minute
      t.integer :hour
      t.integer :day
      t.string :day_of_the_week
      t.integer :day_of_the_year
      t.integer :week_of_the_year
      t.string :month
      t.integer :year
    end
  end
end
