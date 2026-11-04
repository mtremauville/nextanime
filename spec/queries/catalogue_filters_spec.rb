require "rails_helper"

RSpec.describe CatalogueFilters do
  def filters(params = {})
    described_class.from_params(ActionController::Parameters.new(params))
  end

  describe "without any filter" do
    subject(:empty) { filters }

    it "is not active" do
      expect(empty).not_to be_active
    end

    it "has nothing selected" do
      expect(empty.genre_ids).to eq([])
      expect(empty.formats).to eq([])
      expect(empty.statuses).to eq([])
      expect(empty.season).to be_nil
      expect(empty.year_from).to be_nil
      expect(empty.year_to).to be_nil
    end

    it "has no query params" do
      expect(empty.to_query_params).to eq({})
    end
  end

  describe "genre ids" do
    it "reads the ids as numbers" do
      expect(filters(genre_ids: %w[3 5]).genre_ids).to eq([ 3, 5 ])
    end

    it "ignores blanks, texts, zero and negative numbers" do
      expect(filters(genre_ids: [ "", "abc", "0", "-2", "7" ]).genre_ids).to eq([ 7 ])
    end

    it "lists each id once" do
      expect(filters(genre_ids: %w[4 4 2]).genre_ids).to eq([ 4, 2 ])
    end

    it "accepts a single value" do
      expect(filters(genre_ids: "4").genre_ids).to eq([ 4 ])
    end

    it "ignores a value that is neither a text nor a list of texts" do
      expect(filters(genre_ids: { "a" => "1" }).genre_ids).to eq([])
    end
  end

  describe "formats" do
    it "keeps the known formats" do
      expect(filters(formats: %w[tv movie]).formats).to eq(%w[tv movie])
    end

    it "ignores unknown formats and the ones the catalogue does not offer" do
      expect(filters(formats: %w[banana music ova]).formats).to eq(%w[ova])
    end
  end

  describe "statuses" do
    it "keeps the known statuses" do
      expect(filters(statuses: %w[finished releasing]).statuses).to eq(%w[finished releasing])
    end

    it "ignores unknown statuses and the ones the catalogue does not offer" do
      expect(filters(statuses: %w[cancelled not_yet_released]).statuses).to eq(%w[not_yet_released])
    end
  end

  describe "season" do
    it "keeps a known season" do
      expect(filters(season: "fall").season).to eq("fall")
    end

    it "ignores an unknown or empty season" do
      expect(filters(season: "banana").season).to be_nil
      expect(filters(season: "").season).to be_nil
    end

    it "ignores a list of seasons" do
      expect(filters(season: %w[fall winter]).season).to be_nil
    end
  end

  describe "years" do
    it "reads the first and the last year" do
      selected = filters(year_from: "1995", year_to: "2005")

      expect([ selected.year_from, selected.year_to ]).to eq([ 1995, 2005 ])
    end

    it "ignores texts and empty values" do
      selected = filters(year_from: "abc", year_to: "")

      expect([ selected.year_from, selected.year_to ]).to eq([ nil, nil ])
    end

    it "puts the years back in order when they are reversed" do
      selected = filters(year_from: "2010", year_to: "1990")

      expect([ selected.year_from, selected.year_to ]).to eq([ 1990, 2010 ])
    end

    it "keeps a single year" do
      selected = filters(year_from: "2000")

      expect([ selected.year_from, selected.year_to ]).to eq([ 2000, nil ])
    end
  end

  describe "#active?" do
    {
      genre_ids: %w[1],
      formats: %w[tv],
      statuses: %w[finished],
      season: "winter",
      year_from: "1990",
      year_to: "2000"
    }.each do |name, value|
      it "is active as soon as #{name} is given" do
        expect(filters(name => value)).to be_active
      end
    end
  end

  describe "#to_query_params" do
    it "gives back only what is selected, ready for an address" do
      selected = filters(genre_ids: %w[3], formats: %w[tv], statuses: %w[finished], season: "fall", year_from: "1990", year_to: "2000")

      expect(selected.to_query_params).to eq(
        genre_ids: [ 3 ], formats: %w[tv], statuses: %w[finished], season: "fall", year_from: 1990, year_to: 2000
      )
    end

    it "leaves out what is empty" do
      expect(filters(formats: %w[ova], season: "").to_query_params).to eq(formats: %w[ova])
    end
  end

  describe "without params" do
    it "is the same as no filter" do
      expect(described_class.from_params(nil)).not_to be_active
    end
  end
end
