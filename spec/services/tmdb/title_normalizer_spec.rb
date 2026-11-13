require "rails_helper"

RSpec.describe Tmdb::TitleNormalizer do
  describe ".normalize" do
    {
      "Hunter x Hunter (2011)" => "hunterxhunter",
      "HUNTER×HUNTER" => "hunterxhunter",
      "Naruto Shippūden" => "narutoshippuden",
      "A Silent Voice: The Movie" => "asilentvoice",
      "映画 聲の形" => "聲の形",
      "劇場版 聲の形" => "聲の形",
      "JoJo's Bizarre Adventure (TV)" => "jojosbizarreadventure",
      "進撃の巨人 Season２" => "進撃の巨人season2",
      "FRIEREN - Beyond Journey's End!" => "frierenbeyondjourneysend",
      "Attack on Titan Season 2" => "attackontitanseason2",
      "!!!" => ""
    }.each do |title, normalized|
      it "turns #{title.inspect} into #{normalized.inspect}" do
        expect(described_class.normalize(title)).to eq(normalized)
      end
    end
  end

  describe ".search_term" do
    {
      "JoJo's Bizarre Adventure (TV)" => "JoJo's Bizarre Adventure",
      "Hunter x Hunter (2011)" => "Hunter x Hunter",
      "Frieren: Beyond Journey's End" => "Frieren: Beyond Journey's End"
    }.each do |title, term|
      it "searches #{term.inspect} for #{title.inspect}" do
        expect(described_class.search_term(title)).to eq(term)
      end
    end
  end
  describe ".series_title" do
    {
      "Attack on Titan Season 3" => "Attack on Titan",
      "Attack on Titan Season 3 Part 2" => "Attack on Titan",
      "Attack on Titan Final Season Part 2" => "Attack on Titan",
      "HAIKYU!! 2nd Season" => "HAIKYU!!",
      "Sword Art Online II" => "Sword Art Online",
      "Overlord III" => "Overlord",
      "Mob Psycho 100 II" => "Mob Psycho 100",
      "Boku no Hero Academia 2" => "Boku no Hero Academia",
      "JUJUTSU KAISEN Season 2" => "JUJUTSU KAISEN",
      "Re:ZERO -Starting Life in Another World- Season2" => "Re:ZERO -Starting Life in Another World-",
      "Mob Psycho 100" => "Mob Psycho 100",
      "Frieren: Beyond Journey's End" => "Frieren: Beyond Journey's End",
      "Demon Slayer: Kimetsu no Yaiba Entertainment District Arc" => "Demon Slayer: Kimetsu no Yaiba Entertainment District Arc"
    }.each do |title, series_title|
      it "turns #{title.inspect} into #{series_title.inspect}" do
        expect(described_class.series_title(title)).to eq(series_title)
      end
    end
  end
end
