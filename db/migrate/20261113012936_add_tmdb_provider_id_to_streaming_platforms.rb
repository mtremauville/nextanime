class AddTmdbProviderIdToStreamingPlatforms < ActiveRecord::Migration[8.1]
  def change
    add_column :streaming_platforms, :tmdb_provider_id, :integer
    add_index :streaming_platforms, :tmdb_provider_id, unique: true
  end
end
