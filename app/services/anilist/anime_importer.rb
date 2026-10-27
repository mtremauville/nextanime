module Anilist
  class AnimeImporter
    def import(media)
      ApplicationRecord.transaction do
        anime = Anime.find_or_initialize_by(anilist_id: media.fetch("id"))
        anime.update!(attributes_from(media))

        replace_genres(anime, media.fetch("genres"))
        replace_tags(anime, media.fetch("tags"))
        replace_studios(anime, media.dig("studios", "edges"))
        anime
      end
    end

    private

    def attributes_from(media)
      {
        title_romaji: media.dig("title", "romaji"),
        title_english: media.dig("title", "english"),
        title_native: media.dig("title", "native"),
        description: media["description"],
        cover_image_url: media.dig("coverImage", "large"),
        banner_image_url: media["bannerImage"],
        format: media["format"],
        airing_status: media["status"],
        season: media["season"],
        season_year: media["seasonYear"],
        episodes: media["episodes"],
        duration: media["duration"],
        average_score: media["averageScore"],
        popularity: media["popularity"],
        start_date: date_from(media["startDate"]),
        end_date: date_from(media["endDate"]),
        next_episode: media.dig("nextAiringEpisode", "episode"),
        next_airing_at: time_from(media.dig("nextAiringEpisode", "airingAt")),
        synced_at: Time.current
      }
    end

    def date_from(fuzzy_date)
      return unless fuzzy_date && fuzzy_date["year"]

      Date.new(fuzzy_date["year"], fuzzy_date["month"] || 1, fuzzy_date["day"] || 1)
    end

    def time_from(epoch_seconds)
      Time.zone.at(epoch_seconds) if epoch_seconds
    end

    def replace_genres(anime, names)
      anime.genres = names.map { |name| Genre.find_or_create_by!(name: name) }
    end

    def replace_tags(anime, tags)
      anime.anime_tags.destroy_all

      tags.each do |data|
        tag = Tag.find_or_initialize_by(anilist_tag_id: data.fetch("id"))
        tag.update!(name: data.fetch("name"), category: data["category"], adult: data.fetch("isAdult"))
        anime.anime_tags.create!(tag: tag, rank: data.fetch("rank"))
      end
    end

    def replace_studios(anime, edges)
      anime.anime_studios.destroy_all

      edges.each do |edge|
        node = edge.fetch("node")
        next unless node.fetch("isAnimationStudio")

        studio = Studio.find_or_initialize_by(anilist_studio_id: node.fetch("id"))
        studio.update!(name: node.fetch("name"))
        anime.anime_studios.create!(studio: studio, main: edge.fetch("isMain"))
      end
    end
  end
end
