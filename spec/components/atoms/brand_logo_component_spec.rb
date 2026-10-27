require "rails_helper"

RSpec.describe Atoms::BrandLogoComponent, type: :component do
  before { render_inline(described_class.new) }

  it "links to the home page" do
    expect(page).to have_link("NextAnime", href: "/")
  end

  it "shows the brand as text" do
    expect(page).to have_css("a.na-brand .na-brand__name", text: "NextAnime")
  end

  it "shows a decorative mark, hidden from assistive technologies" do
    expect(page).to have_css("a.na-brand .na-brand__mark[aria-hidden='true'][lang='ja']", text: "次")
  end
end
