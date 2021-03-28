class CreateStickers < ActiveRecord::Migration[5.2]
  def change
    create_table :stickers do |t|
      t.integer :note_id
      t.string :image
      t.timestamps null: false
    end
  end
end
