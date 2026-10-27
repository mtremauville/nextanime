class CreateWatchlistEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :watchlist_entries do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :anime, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :progress, null: false, default: 0

      t.timestamps
    end

    add_index :watchlist_entries, [ :user_id, :anime_id ], unique: true
    add_index :watchlist_entries, [ :user_id, :status ]
  end
end
