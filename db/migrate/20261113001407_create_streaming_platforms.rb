class CreateStreamingPlatforms < ActiveRecord::Migration[8.1]
  def change
    create_table :streaming_platforms do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :streaming_platforms, :name, unique: true
    add_index :streaming_platforms, :slug, unique: true
  end
end
