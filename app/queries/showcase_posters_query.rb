# The covers of the anime on the posters of the showcase (the landing page and the authentication
# pages), by the name the showcase gives them. An anime that is not in the database yet, or has
# no cover, is left out: its poster then keeps the gradient it has by default.
class ShowcasePostersQuery
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
