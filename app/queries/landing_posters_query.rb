# The covers of the anime that the landing page shows, by the name the page gives them.
# An anime that is not in the database yet, or has no cover, is left out: the page then
# keeps the gradient it has by default.
class LandingPostersQuery
  ANILIST_IDS = {
    death_note: 1535,
    perfect_blue: 437,
    cowboy_bebop: 1,
    chainsaw_man: 127_230,
    eighty_six: 116_589
  }.freeze

  def call
    covers = Anime.where(anilist_id: ANILIST_IDS.values)
                  .where.not(cover_image_url: nil)
                  .pluck(:anilist_id, :cover_image_url)
                  .to_h

    ANILIST_IDS.filter_map { |name, anilist_id| [ name, covers[anilist_id] ] if covers.key?(anilist_id) }.to_h
  end
end
