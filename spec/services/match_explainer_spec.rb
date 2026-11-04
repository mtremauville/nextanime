require "rails_helper"

RSpec.describe MatchExplainer, type: :service do
  let(:profile_class) { Struct.new(:genre_weights, :tag_weights) }
  let(:anime_class) { Struct.new(:genres, :anime_tags) }
  let(:named) { Struct.new(:name) }
  let(:ranked_tag) { Struct.new(:rank, :tag) }

  def anime_with(genres: [], tags: {})
    anime_class.new(
      genres.map { |name| named.new(name) },
      tags.map { |name, rank| ranked_tag.new(rank, named.new(name)) }
    )
  end

  def explain(anime, genre_weights: {}, tag_weights: {})
    described_class.new(profile_class.new(genre_weights, tag_weights)).call(anime)
  end

  it "names the tags the profile loves, the most loved first" do
    anime = anime_with(tags: { "Gore" => 90, "Mind Games" => 80, "Thriller" => 70 })
    weights = { "Gore" => 0.2, "Mind Games" => 0.9, "Thriller" => 0.5 }

    expect(explain(anime, tag_weights: weights)).to eq("Parce que tu aimes Mind Games, Thriller et Gore.")
  end

  it "keeps three names at most and puts the tags before the genres" do
    anime = anime_with(genres: [ "Drama" ], tags: { "Gore" => 90, "Mind Games" => 80, "Thriller" => 70 })
    weights = { "Gore" => 0.2, "Mind Games" => 0.9, "Thriller" => 0.5 }

    sentence = explain(anime, genre_weights: { "Drama" => 1.0 }, tag_weights: weights)

    expect(sentence).to eq("Parce que tu aimes Mind Games, Thriller et Gore.")
  end

  it "completes with the genres when there are few tags in common" do
    anime = anime_with(genres: %w[Horror Drama], tags: { "Gore" => 80 })

    sentence = explain(anime, genre_weights: { "Horror" => 0.8, "Drama" => 0.3 }, tag_weights: { "Gore" => 0.4 })

    expect(sentence).to eq("Parce que tu aimes Gore, Horror et Drama.")
  end

  it "names the genres alone when no tag is in common" do
    anime = anime_with(genres: [ "Horror" ], tags: { "Gore" => 80 })

    expect(explain(anime, genre_weights: { "Horror" => 0.8 })).to eq("Parce que tu aimes Horror.")
  end

  it "joins two names with et" do
    anime = anime_with(genres: %w[Horror Drama])

    sentence = explain(anime, genre_weights: { "Horror" => 0.8, "Drama" => 0.3 })

    expect(sentence).to eq("Parce que tu aimes Horror et Drama.")
  end

  it "ignores what the profile rejects, is neutral about or does not know" do
    anime = anime_with(tags: { "Gore" => 80, "Ecchi" => 70, "Isekai" => 60 })

    expect(explain(anime, tag_weights: { "Gore" => -0.5, "Ecchi" => 0.0 })).to be_nil
  end

  it "says nothing about an anime without any genre or tag" do
    expect(explain(anime_with)).to be_nil
  end
end
