class CreateDynamicModelTables < ActiveRecord::Migration
  def change
    # dynamic_attributes table
    create_table :dynamic_attributes do |t|
      t.string  :class_type, :null => false, :size => 50
      t.string  :name, :null => false, :size => 100
      
      # 0 - String, 1 - Boolean, 2 - Date, 3 - Integer, 4 - Float, 5 - Text 
      t.string  :type, :null => false, :size => 10
      t.integer  :length, :null => false, :default => 50
      t.boolean  :required, :null => false, :default => 0

      t.text  :default
      t.timestamps
    end
    add_index :dynamic_attributes, [:class_type, :name], :unique => true 
    
    # dynamic_values table
    create_table :dynamic_values do |t|
      t.string   :class_type, :null => false, :size => 50 # Denormalization
      t.string   :name, :null => false, :size => 100
      t.integer  :item_id, :null => false
      t.text  :value

      t.timestamps
    end
    add_index :dynamic_values, [:class_type, :name, :item_id]
    
  end
end