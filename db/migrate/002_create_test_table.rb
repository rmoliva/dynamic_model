class CreateTestTable < ActiveRecord::Migration
  def change
    # dynamic_attributes table
    create_table :test_table do |t|
        t.string  :name
    end
  end 
end