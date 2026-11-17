require "rails_helper"

RSpec.describe "Catalogue", type: :request do
  let(:thriller) { create(:genre, name: "Thriller") }
  let(:document) { Capybara.string(response.body) }

  def create_ranked_animes(count)
    count.times do |index|
      create(:anime, title_romaji: "Anime #{index}", title_english: nil, popularity: 1000 - index)
    end
  end

  def titles = document.all("[data-role='catalogue-item'] h2").map { |node| node.text.strip }

  describe "GET /catalogue" do
    it "shows the catalogue to a visitor" do
      create_ranked_animes(2)

      get catalogue_path

      expect(response).to have_http_status(:ok)
      expect(document).to have_css("h1", text: "Catalogue")
    end

    it "lists the most popular anime first" do
      create(:anime, title_romaji: "Quiet", title_english: nil, popularity: 1)
      create(:anime, title_romaji: "Famous", title_english: nil, popularity: 900)

      get catalogue_path

      expect(titles).to eq(%w[Famous Quiet])
    end

    it "counts the results" do
      create_ranked_animes(3)

      get catalogue_path

      expect(document).to have_css("[data-role='results']", text: "3 résultats")
    end

    it "counts a single result in the singular" do
      create_ranked_animes(1)

      get catalogue_path

      expect(document).to have_css("[data-role='results']", text: "1 résultat")
    end

    context "with more than one page" do
      before { create_ranked_animes(13) }

      it "shows twelve anime on the first page" do
        get catalogue_path

        expect(titles.size).to eq(12)
      end

      it "shows the other anime on the next page" do
        get catalogue_path(page: 2)

        expect(titles).to eq([ "Anime 12" ])
      end

      it "brings a page that does not exist back to the last one" do
        get catalogue_path(page: 99)

        expect(titles).to eq([ "Anime 12" ])
      end

      it "brings something that is not a page number back to the first one" do
        get catalogue_path(page: "abc")

        expect(titles.size).to eq(12)
      end

      it "links to the next page from the pagination" do
        get catalogue_path

        expect(document).to have_css("nav[aria-label='Pagination'] a[rel='next'][href='/catalogue?page=2']")
      end

      it "offers to load more anime and tells how many are shown" do
        get catalogue_path

        expect(document).to have_css("#load-more [data-role='progress']", text: "12 sur 13")
        expect(document).to have_css("#load-more a[href='/catalogue?page=2']", text: "Voir plus")
      end

      it "offers nothing more to load on the last page" do
        get catalogue_path(page: 2)

        expect(document).to have_css("#load-more [data-role='progress']", text: "13 sur 13")
        expect(document).to have_no_css("#load-more a")
      end
    end

    it "shows no pagination when everything fits on one page" do
      create_ranked_animes(2)

      get catalogue_path

      expect(document).to have_no_css("nav[aria-label='Pagination']")
    end

    it "does not create a taste profile just to look" do
      create_ranked_animes(2)

      expect { get catalogue_path }.not_to change(TasteProfile, :count)
    end

    context "without a taste profile" do
      it "shows no match" do
        create_ranked_animes(2)

        get catalogue_path

        expect(document).to have_no_css(".na-badge-match")
      end
    end

    context "with passes only" do
      it "shows no match" do
        user = create(:user)
        sign_in user
        user.create_taste_profile!.record_swipe(create(:anime), liked: false)

        get catalogue_path

        expect(document).to have_no_css(".na-badge-match")
      end
    end

    context "with likes" do
      it "shows how well each anime matches the taste" do
        user = create(:user)
        sign_in user
        user.create_taste_profile!.record_swipe(create(:anime, genres: [ thriller ]), liked: true)
        create(:anime, title_romaji: "Monster", title_english: nil, genres: [ thriller ])

        get catalogue_path

        expect(document).to have_css("[data-role='catalogue-item'] .na-badge-match [aria-hidden='true']", text: /\d+%/)
      end
    end
  end

  describe "GET /catalogue as a turbo stream" do
    let(:headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

    before { create_ranked_animes(13) }

    # The HTML of a stream sits in a template, where a CSS selector does not look.
    def stream_content(action, target)
      pattern = %r{<turbo-stream action="#{action}" target="#{target}"><template>(.*?)</template></turbo-stream>}m
      Capybara.string(response.body[pattern, 1].to_s)
    end

    it "adds the anime of the page to the grid" do
      get catalogue_path(page: 2), headers: headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(stream_content("append", "catalogue-grid")).to have_css("li[data-role='catalogue-item']", count: 1)
    end

    it "replaces the load more block with the next link" do
      get catalogue_path(page: 1), headers: headers

      expect(stream_content("replace", "load-more")).to have_css("a[href='/catalogue?page=2']", text: "Voir plus")
    end

    it "replaces the load more block without link on the last page" do
      get catalogue_path(page: 2), headers: headers

      block = stream_content("replace", "load-more")
      expect(block).to have_css("[data-role='progress']", text: "13 sur 13")
      expect(block).to have_no_css("a")
    end
  end

  describe "GET /catalogue with a search" do
    before do
      create_ranked_animes(3)
      13.times do |index|
        create(:anime, title_romaji: "Monster #{index}", title_english: nil, popularity: 500 - index)
      end
    end

    it "lists only the anime that match" do
      get catalogue_path(q: "monster")

      expect(titles.size).to eq(12)
      expect(titles).to all(start_with("Monster"))
    end

    it "counts the matches only" do
      get catalogue_path(q: "monster")

      expect(document).to have_css("[data-role='results']", text: "13 résultats")
    end

    it "shows the text that was searched in the field" do
      get catalogue_path(q: "monster")

      expect(document).to have_field("Rechercher un anime", with: "monster")
    end

    it "keeps the search in the links of the pagination" do
      get catalogue_path(q: "monster")

      expect(document).to have_css("nav[aria-label='Pagination'] a[rel='next'][href='/catalogue?page=2&q=monster']")
    end

    it "keeps the search in the load more link" do
      get catalogue_path(q: "monster")

      expect(document).to have_css("#load-more a[href='/catalogue?page=2&q=monster']")
    end

    it "shows the next matches on the next page" do
      get catalogue_path(q: "monster", page: 2)

      expect(titles).to eq([ "Monster 12" ])
    end

    it "keeps the search when more anime are loaded with a turbo stream" do
      get catalogue_path(q: "monster", page: 1), headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include('href="/catalogue?page=2&amp;q=monster"')
    end

    it "shows an empty grid, not an error, when nothing matches" do
      get catalogue_path(q: "zzz")

      expect(response).to have_http_status(:ok)
      expect(titles).to be_empty
      expect(document).to have_css("[data-role='results']", text: "0 résultat")
    end

    it "ignores a search that is not a text" do
      get catalogue_path(q: [ "monster" ])

      expect(response).to have_http_status(:ok)
      expect(titles.size).to eq(12)
    end
  end
  describe "the platforms of the anime" do
    let(:monster) { create(:anime, title_romaji: "Monster", title_english: nil) }
    let(:netflix) { create(:streaming_platform, name: "Netflix", slug: "netflix") }

    def offer(country_code, anime: monster)
      create(:streaming_availability, anime: anime, streaming_platform: netflix, country_code: country_code)
    end

    it "shows the platforms of the anime in France by default" do
      offer("FR")

      get catalogue_path

      expect(document).to have_css("[data-role='catalogue-item'] .na-platform-badges", text: "Netflix")
    end

    it "shows the platforms of the country that was chosen" do
      offer("BE")
      patch country_path, params: { country: "BE" }

      get catalogue_path

      expect(document).to have_css("[data-role='catalogue-item'] .na-platform-badges", text: "Netflix")
    end

    it "does not show the platforms of another country" do
      offer("BE")

      get catalogue_path

      expect(document).to have_no_css(".na-platform-badges")
    end

    it "shows the platforms on the cards that are added by load more as well" do
      offer("FR")

      get catalogue_path, headers: { "Accept" => Mime[:turbo_stream].to_s }

      expect(response.body).to include("na-platform-badges")
    end

    it "looks the platforms up once for the whole page" do
      create_list(:anime, 3).each { |listed| offer("FR", anime: listed) }
      loads = []
      callback = ->(*, payload) { loads << payload[:name] }

      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { get catalogue_path }

      expect(loads.count("StreamingAvailability Load")).to eq(1)
    end
  end
  describe "the platform filter" do
    let(:crunchyroll) { create(:streaming_platform, name: "Crunchyroll") }
    let(:netflix) { create(:streaming_platform, name: "Netflix") }

    def offer(title, platform, country_code: "FR")
      anime = create(:anime, title_romaji: title, title_english: nil)
      create(:streaming_availability, anime: anime, streaming_platform: platform,
                                      country_code: country_code, offer_type: "flatrate")
    end

    before do
      offer("On Crunchyroll", crunchyroll)
      offer("On Netflix", netflix)
      offer("Only in the US", crunchyroll, country_code: "US")
      create(:anime, title_romaji: "No offer", title_english: nil)
    end

    it "offers the platforms of the country in the filters" do
      get catalogue_path

      expect(document).to have_css("input[name='platform_ids[]'][value='#{crunchyroll.id}']")
      expect(document).to have_css("input[name='platform_ids[]'][value='#{netflix.id}']")
    end

    it "keeps the anime available on the chosen platform" do
      get catalogue_path, params: { platform_ids: [ crunchyroll.id ] }

      expect(titles).to eq([ "On Crunchyroll" ])
    end

    it "looks at the offers of the country of the visitor" do
      patch country_path, params: { country: "US" }

      get catalogue_path, params: { platform_ids: [ crunchyroll.id ] }

      expect(titles).to eq([ "Only in the US" ])
    end

    it "shows a chip, linked to the catalogue without it, for the chosen platform" do
      get catalogue_path, params: { platform_ids: [ crunchyroll.id ] }

      expect(document).to have_link(href: catalogue_path, text: /Crunchyroll/)
    end

    it "keeps offering a chosen platform that has no offer in the country" do
      idle = create(:streaming_platform, name: "Idle")

      get catalogue_path, params: { platform_ids: [ idle.id ] }

      expect(document).to have_checked_field("Idle")
    end
  end
end
