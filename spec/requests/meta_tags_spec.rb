require "rails_helper"

RSpec.describe "Meta tags", type: :request do
  pages = {
    "a page of the application" => :catalogue_path,
    "a page of the sign in layout" => :new_user_session_path
  }

  let(:description) do
    "Swipe tes références, NextAnime cerne ta vibe et te propose des anime qui te ressemblent, pas ceux que tout le monde regarde."
  end

  def document
    Nokogiri::HTML(response.body)
  end

  def content_of(selector)
    document.at_css(selector)&.[]("content")
  end

  pages.each do |layout, route|
    context "on #{layout}" do
      before { get public_send(route) }

      it "describes the site for the search engines" do
        expect(content_of("meta[name='description']")).to eq(description)
      end

      it "describes the site for the shared links" do
        expect(content_of("meta[property='og:description']")).to eq(description)
      end

      it "gives the shared links the title of the page" do
        expect(content_of("meta[property='og:title']")).to eq(document.at_css("title").text)
      end

      it "declares a website named NextAnime, in French" do
        expect(content_of("meta[property='og:type']")).to eq("website")
        expect(content_of("meta[property='og:site_name']")).to eq("NextAnime")
        expect(content_of("meta[property='og:locale']")).to eq("fr_FR")
      end

      it "gives the address of the page, without its query" do
        expect(content_of("meta[property='og:url']")).to eq("#{request.base_url}#{request.path}")
      end

      it "gives an absolute address to the shared image" do
        expect(content_of("meta[property='og:image']")).to eq("#{request.base_url}/og-image.png")
      end

      it "asks for a large image card" do
        expect(content_of("meta[name='twitter:card']")).to eq("summary_large_image")
      end

      it "spells the brand in one word" do
        expect(document.at_css("head").to_html).not_to include("Next Anime")
      end
    end
  end

  it "titles the sign in page with its name, then the brand" do
    get new_user_session_path

    expect(document.at_css("title").text).to eq("Connexion · NextAnime")
  end

  it "ships the image that the shared links point to" do
    expect(Rails.public_path.join("og-image.png")).to exist
  end
end
