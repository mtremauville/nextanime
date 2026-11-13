class CreateStreamingLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :streaming_links do |t|
      t.references :anime, null: false, foreign_key: true
      t.references :streaming_platform, null: false, foreign_key: true
      t.string :url, null: false
      t.string :language

      t.timestamps
    end

    add_index :streaming_links, %i[anime_id url], unique: true
  end
end
