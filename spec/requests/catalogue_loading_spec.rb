require "rails_helper"

RSpec.describe "Catalogue loading state", type: :request do
  before { create(:anime) }

  let(:page) { Capybara.string(response.body) }

  it "lets the page mark the results as busy as soon as a form is sent" do
    get catalogue_path

    expect(page).to have_css(".na-catalogue-layout[data-controller='pending'][data-action*='turbo:submit-start->pending#start']")
  end

  it "holds the skeleton cards that the style shows in place of the grid while it is busy" do
    get catalogue_path

    expect(page).to have_css(".na-catalogue-layout .na-catalogue-skeleton .na-skeleton-card", count: 12, visible: :all)
  end
end
