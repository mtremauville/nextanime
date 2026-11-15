class AddWatchLinksToTmdbMatches < ActiveRecord::Migration[8.1]
  def change
    add_column :tmdb_matches, :watch_links, :jsonb, null: false, default: {}
  end
end
