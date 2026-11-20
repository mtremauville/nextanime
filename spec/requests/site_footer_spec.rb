require "rails_helper"

RSpec.describe "The site footer", type: :request do
  let(:document) { Capybara.string(response.body) }
  let(:notice) { "This product uses the TMDB API" }

  it "credits the sources of the data on the catalogue" do
    get catalogue_path

    expect(document).to have_css("footer.na-site-footer", text: notice)
  end

  it "credits them on the page of an anime" do
    get anime_path(create(:anime))

    expect(document).to have_css("footer.na-site-footer", text: notice)
  end

  it "credits them on the watchlist of a member" do
    sign_in create(:user)

    get watchlist_path

    expect(document).to have_css("footer.na-site-footer", text: notice)
  end

  it "shows the footer once, after the main content" do
    get catalogue_path

    expect(document).to have_css("footer.na-site-footer", count: 1)
    expect(document).to have_css("main#main + footer.na-site-footer")
  end
end
