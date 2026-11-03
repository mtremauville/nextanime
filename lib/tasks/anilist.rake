namespace :anilist do
  desc "Enqueue the import of the most popular anime from AniList (default: 500)"
  task :import, [ :limit ] => :environment do |_task, args|
    limit = Integer(args[:limit] || ImportTopAnimeJob::TOP_ANIME_LIMIT)

    ImportTopAnimeJob.perform_later(page: 1, remaining: limit)
    $stdout.puts "Import of the top #{limit} anime enqueued"
  end
end
