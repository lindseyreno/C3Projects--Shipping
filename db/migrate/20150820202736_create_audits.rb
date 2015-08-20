class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.integer :order_id
      t.string :shipping_service
      t.integer :shipping_cost

      t.timestamps null: false
    end
  end
end
