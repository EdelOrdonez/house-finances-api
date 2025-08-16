class CreateStrategies < ActiveRecord::Migration[8.0]
  def change
    create_table :strategies do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    
    add_index :strategies, :name, unique: true
  end
end
