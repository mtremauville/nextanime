class SyncAnimeBatchJob < ApplicationJob
  include AnilistResilient

  queue_as :default

  def perform(anilist_ids)
    importer = Anilist::AnimeImporter.new

    Anilist::Client.new.media_by_ids(anilist_ids).each { |media| refresh(importer, media) }
  end

  private

  def refresh(importer, media)
    importer.import(media)
  rescue ActiveRecord::RecordInvalid => error
    Rails.logger.warn("SyncAnimeBatchJob skipped anime #{media['id']}: #{error.message}")
  end
end
