class AddLogoPathToStreamingPlatforms < ActiveRecord::Migration[8.1]
  def change
    add_column :streaming_platforms, :logo_path, :string
  end
end
