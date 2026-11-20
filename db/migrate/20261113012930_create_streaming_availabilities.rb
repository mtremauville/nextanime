class CreateStreamingAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :streaming_availabilities do |t|
      t.references :anime, null: false, foreign_key: true
      t.references :streaming_platform, null: false, foreign_key: true, index: false
      t.string :country_code, null: false
      t.string :offer_type, null: false

      t.timestamps
    end

    add_index :streaming_availabilities, %i[anime_id streaming_platform_id country_code offer_type],
              unique: true, name: "index_streaming_availabilities_uniqueness"
    add_index :streaming_availabilities, %i[streaming_platform_id country_code],
              name: "index_streaming_availabilities_on_platform_and_country"
  end
end
