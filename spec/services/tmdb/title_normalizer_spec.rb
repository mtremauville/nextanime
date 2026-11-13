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
end
