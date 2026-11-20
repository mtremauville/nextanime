namespace :anilist do
  desc "Enqueue the import of the most popular anime from AniList (default: 500)"
  task :import, [ :limit ] => :environment do |_task, args|
    limit = Integer(args[:limit] || ImportTopAnimeJob::TOP_ANIME_LIMIT)

    ImportTopAnimeJob.perform_later(page: 1, remaining: limit)
    $stdout.puts "Import of the top #{limit} anime enqueued"
  end

  desc "Enqueue the import of the anime that are airing now from AniList (default: 500)"
  task :import_airing, [ :limit ] => :environment do |_task, args|
    limit = Integer(args[:limit] || ImportAiringAnimeJob::AIRING_ANIME_LIMIT)

    ImportAiringAnimeJob.perform_later(page: 1, remaining: limit)
    $stdout.puts "Import of the #{limit} airing anime enqueued"
  end
end
