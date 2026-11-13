# Refreshes the streaming availabilities of the whole catalogue. The batches are spread out so that
# the calls to TMDB stay far below its rate limit.
class SyncStreamingAvailabilitiesJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 25
  PAUSE_BETWEEN_BATCHES = 5.seconds

  def perform
    Anime.order(:id).pluck(:id).each_slice(BATCH_SIZE).with_index do |anime_ids, index|
      SyncStreamingAvailabilitiesBatchJob.set(wait: PAUSE_BETWEEN_BATCHES * index).perform_later(anime_ids)
    end
  end
end
