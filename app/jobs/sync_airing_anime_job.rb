class SyncAiringAnimeJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = Anilist::Client::MAX_IDS_PER_REQUEST
  PAUSE_BETWEEN_BATCHES = 2.seconds

  def perform
    Anime.to_sync.pluck(:anilist_id).each_slice(BATCH_SIZE).with_index do |anilist_ids, index|
      SyncAnimeBatchJob.set(wait: PAUSE_BETWEEN_BATCHES * index).perform_later(anilist_ids)
    end
  end
end
