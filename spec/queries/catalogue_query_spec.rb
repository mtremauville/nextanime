require "rails_helper"

RSpec.describe CatalogueQuery, type: :query do
  def titles(page) = page.animes.map(&:title_romaji)

  def create_ranked_animes(count)
    count.times { |index| create(:anime, title_romaji: "Anime #{index}", popularity: 100 - index) }
  end

  describe "#call" do
    it "lists the most popular anime first" do
      create(:anime, title_romaji: "Quiet", popularity: 10)
      create(:anime, title_romaji: "Famous", popularity: 900)

      expect(titles(described_class.new.call)).to eq(%w[Famous Quiet])
    end

    it "puts the anime without popularity last" do
      create(:anime, title_romaji: "Unknown", popularity: nil)
      create(:anime, title_romaji: "Known", popularity: 5)

      expect(titles(described_class.new.call)).to eq(%w[Known Unknown])
    end

    it "keeps the order stable between anime of the same popularity" do
      create(:anime, title_romaji: "First", popularity: 50)
      create(:anime, title_romaji: "Second", popularity: 50)

      expect(titles(described_class.new.call)).to eq(%w[First Second])
    end

    it "returns only the anime of the asked page" do
      create_ranked_animes(5)

      page = described_class.new(page: 2, per_page: 2).call

      expect(titles(page)).to eq([ "Anime 2", "Anime 3" ])
      expect(page.number).to eq(2)
    end

    it "reads the page number of a request parameter" do
      create_ranked_animes(5)

      expect(described_class.new(page: "2", per_page: 2).call.number).to eq(2)
    end

    it "falls back to the first page for a number below one" do
      create_ranked_animes(3)

      expect(described_class.new(page: -3, per_page: 2).call.number).to eq(1)
    end

    it "falls back to the first page for something that is not a number" do
      create_ranked_animes(3)

      expect(described_class.new(page: "abc", per_page: 2).call.number).to eq(1)
      expect(described_class.new(page: nil, per_page: 2).call.number).to eq(1)
    end

    it "falls back to the last page for a number beyond it" do
      create_ranked_animes(5)

      page = described_class.new(page: 99, per_page: 2).call

      expect(page.number).to eq(3)
      expect(titles(page)).to eq([ "Anime 4" ])
    end

    it "counts the whole catalogue and its pages" do
      create_ranked_animes(5)

      page = described_class.new(per_page: 2).call

      expect(page.total_count).to eq(5)
      expect(page.total_pages).to eq(3)
    end

    it "gives one empty page for an empty catalogue" do
      page = described_class.new.call

      expect(page.animes).to be_empty
      expect([ page.number, page.total_pages, page.total_count ]).to eq([ 1, 1, 0 ])
    end

    it "gives the numbers of the previous and next pages" do
      create_ranked_animes(5)

      first = described_class.new(page: 1, per_page: 2).call
      last = described_class.new(page: 3, per_page: 2).call

      expect([ first.previous_number, first.next_number ]).to eq([ nil, 2 ])
      expect([ last.previous_number, last.next_number ]).to eq([ 2, nil ])
    end

    it "counts the anime shown up to the end of the page" do
      create_ranked_animes(5)

      expect(described_class.new(page: 2, per_page: 2).call.shown_count).to eq(4)
      expect(described_class.new(page: 3, per_page: 2).call.shown_count).to eq(5)
    end

    it "loads what a card needs beforehand" do
      create(:anime)

      anime = described_class.new.call.animes.first

      expect(anime.association(:genres)).to be_loaded
      expect(anime.association(:main_studio)).to be_loaded
      expect(anime.association(:anime_tags)).to be_loaded
    end
  end

  describe "#call with a search" do
    def create_anime(title, **attributes)
      create(:anime, title_romaji: title, title_english: nil, title_native: nil, **attributes)
    end

    def search_titles(text) = titles(described_class.new(search: text).call)

    it "finds an anime by a part of its title, whatever the case" do
      create_anime("Monster")
      create_anime("Frieren")

      expect(search_titles("MONST")).to eq(%w[Monster])
    end

    it "finds an anime by its English title" do
      create_anime("Sousou no Frieren", title_english: "Frieren: Beyond Journey's End")
      create_anime("Monster")

      expect(search_titles("beyond")).to eq([ "Sousou no Frieren" ])
    end

    it "finds an anime by its native title" do
      create_anime("Sousou no Frieren", title_native: "葬送のフリーレン")
      create_anime("Monster")

      expect(search_titles("フリーレン")).to eq([ "Sousou no Frieren" ])
    end

    it "finds an anime by the name of one of its studios, not only the main one" do
      mappa = create(:studio, name: "MAPPA")
      create_anime("Jujutsu Kaisen", studios: [ mappa ])
      create_anime("Monster")

      expect(search_titles("mappa")).to eq([ "Jujutsu Kaisen" ])
    end

    it "lists an anime once even when several things match" do
      studios = [ create(:studio, name: "MAPPA"), create(:studio, name: "MAPPA Pro") ]
      create_anime("Mappa Story", studios: studios)

      page = described_class.new(search: "mappa").call

      expect(titles(page)).to eq([ "Mappa Story" ])
      expect(page.total_count).to eq(1)
    end

    it "ignores the blanks around the text" do
      create_anime("Monster")

      expect(search_titles("  monster ")).to eq(%w[Monster])
    end

    it "gives the whole catalogue for a blank text" do
      create_anime("Monster")
      create_anime("Frieren")

      [ nil, "", "   " ].each { |blank| expect(search_titles(blank).size).to eq(2) }
    end

    it "reads % and _ as simple characters" do
      create_anime("100% Pure")
      create_anime("Death_Note")
      create_anime("DeathXNote")

      expect(search_titles("%")).to eq([ "100% Pure" ])
      expect(search_titles("death_n")).to eq([ "Death_Note" ])
    end

    it "keeps the most popular first among the results" do
      create_anime("Monster Quiet", popularity: 1)
      create_anime("Monster Famous", popularity: 900)
      create_anime("Frieren", popularity: 500)

      expect(search_titles("monster")).to eq([ "Monster Famous", "Monster Quiet" ])
    end

    it "pages through the results only" do
      5.times { |index| create_anime("Monster #{index}", popularity: 100 - index) }
      create_anime("Frieren")

      page = described_class.new(search: "monster", page: 3, per_page: 2).call

      expect(titles(page)).to eq([ "Monster 4" ])
      expect([ page.total_count, page.total_pages ]).to eq([ 5, 3 ])
    end

    it "gives one empty page when nothing matches" do
      create_anime("Monster")

      page = described_class.new(search: "zzz").call

      expect(page.animes).to be_empty
      expect([ page.number, page.total_pages, page.total_count ]).to eq([ 1, 1, 0 ])
    end
  end
end
