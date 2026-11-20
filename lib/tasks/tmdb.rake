namespace :tmdb do
  desc "Import the streaming availabilities from TMDB for the most popular anime (default: 100) and print the match rate"
  task :import_availabilities, [ :limit ] => :environment do |_task, args|
    limit = Integer(args[:limit] || Tmdb::AvailabilitySync::DEFAULT_LIMIT)

    $stdout.puts Tmdb::AvailabilitySync.new.call(Anime.most_popular(limit)).to_s
  end
end
