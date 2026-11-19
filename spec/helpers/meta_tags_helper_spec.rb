require "rails_helper"

RSpec.describe MetaTagsHelper, type: :helper do
  describe "#page_title" do
    it "is the name of the site when the page gives no title" do
      expect(helper.page_title).to eq("NextAnime")
    end

    it "is the title that the page gives, followed by the name of the site" do
      helper.content_for(:title, "Connexion")

      expect(helper.page_title).to eq("Connexion · NextAnime")
    end
  end

  describe "#page_description" do
    it "presents the site when the page gives no description" do
      expect(helper.page_description).to start_with("Swipe tes références")
    end

    it "is the description that the page gives" do
      helper.content_for(:description, "Un anime à voir.")

      expect(helper.page_description).to eq("Un anime à voir.")
    end
  end
end
