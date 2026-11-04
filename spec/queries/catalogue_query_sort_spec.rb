require "rails_helper"

RSpec.describe CatalogueQuery, "sorting" do
  def titles_for(sort: nil, scorer: nil, **given)
    described_class.new(sort: sort, scorer: scorer, **given).call.animes.map(&:title_romaji)
  end

  describe "by popularity" do
    before do
      create(:anime, title_romaji: "Low", popularity: 10)
      create(:anime, title_romaji: "None", popularity: nil)
      create(:anime, title_romaji: "High", popularity: 50)
    end

    it "puts the most popular first and the anime without popularity last" do
      expect(titles_for(sort: "popularity")).to eq(%w[High Low None])
    end

    it "is the sort when none is asked" do
      expect(titles_for).to eq(%w[High Low None])
    end

    it "is the sort when the one asked is unknown" do
      expect(titles_for(sort: "banana")).to eq(%w[High Low None])
    end
  end

  describe "by score" do
    it "puts the best rated first, the unrated last, and the most popular among equals" do
      create(:anime, title_romaji: "Fine", average_score: 70, popularity: 5)
      create(:anime, title_romaji: "Best", average_score: 90, popularity: 1)
      create(:anime, title_romaji: "Fine and popular", average_score: 70, popularity: 99)
      create(:anime, title_romaji: "Unrated", average_score: nil, popularity: 500)

      expect(titles_for(sort: "score")).to eq([ "Best", "Fine and popular", "Fine", "Unrated" ])
    end
  end

  describe "by date" do
    it "puts the most recent first and the undated last" do
      create(:anime, title_romaji: "Old", start_date: Date.new(2010, 4, 1), popularity: 1)
      create(:anime, title_romaji: "Undated", start_date: nil, popularity: 2)
      create(:anime, title_romaji: "New", start_date: Date.new(2024, 10, 5), popularity: 3)

      expect(titles_for(sort: "recent")).to eq(%w[New Old Undated])
    end
  end

  describe "by title" do
    it "follows the title that is shown, whatever the case" do
      create(:anime, title_romaji: "Zebra", title_english: "Apple", popularity: 1)
      create(:anime, title_romaji: "bravo", title_english: nil, popularity: 2)
      create(:anime, title_romaji: "Charlie", title_english: "", popularity: 3)

      expect(titles_for(sort: "title")).to eq(%w[Zebra bravo Charlie])
    end
  end

  describe "by match" do
    let(:scores) { { "Low" => 0.2, "Top" => 0.9, "Tie, less popular" => 0.5, "Tie, more popular" => 0.5 } }
    let(:scorer) do
      instance_double(MatchScorer).tap do |double|
        allow(double).to receive(:call) { |anime| scores.fetch(anime.title_romaji) }
      end
    end

    before do
      create(:anime, title_romaji: "Low", popularity: 100)
      create(:anime, title_romaji: "Top", popularity: 1)
      create(:anime, title_romaji: "Tie, less popular", popularity: 10)
      create(:anime, title_romaji: "Tie, more popular", popularity: 20)
    end

    it "puts the closest first, and the most popular among equals" do
      expect(titles_for(sort: "match", scorer: scorer)).to eq([ "Top", "Tie, more popular", "Tie, less popular", "Low" ])
    end

    it "pages through the sorted list" do
      expect(titles_for(sort: "match", scorer: scorer, per_page: 2)).to eq([ "Top", "Tie, more popular" ])
      expect(titles_for(sort: "match", scorer: scorer, per_page: 2, page: 2)).to eq([ "Tie, less popular", "Low" ])
    end

    it "only ranks what the search keeps, and counts it" do
      page = described_class.new(sort: "match", scorer: scorer, search: "Tie").call

      expect(page.animes.map(&:title_romaji)).to eq([ "Tie, more popular", "Tie, less popular" ])
      expect(page.total_count).to eq(2)
    end

    it "loads what a card needs beforehand" do
      anime = described_class.new(sort: "match", scorer: scorer).call.animes.first

      expect(anime.association(:genres)).to be_loaded
      expect(anime.association(:anime_tags)).to be_loaded
    end

    it "falls back to the popularity without a scorer" do
      expect(titles_for(sort: "match")).to eq([ "Low", "Tie, more popular", "Tie, less popular", "Top" ])
    end
  end

  describe ".sorts" do # offered sorts
    it "offers every sort when the match can be told" do
      expect(described_class.sorts(match: true)).to eq(%w[match popularity score recent title])
    end

    it "leaves out the match when it cannot be told" do
      expect(described_class.sorts(match: false)).to eq(%w[popularity score recent title])
    end
  end
end
