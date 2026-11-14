require "rails_helper"

RSpec.describe Molecules::PlatformRowComponent, type: :component do
  let(:platform) { build_stubbed(:streaming_platform, name: "Crunchyroll", logo_path: "/abc.png") }
  let(:address) { "https://www.crunchyroll.com/series/ABC" }

  def render_row(offer_type: "flatrate", url: address)
    render_inline(described_class.new(platform: platform, offer_type: offer_type, url: url))
  end

  it "shows the name of the platform" do
    render_row

    expect(page).to have_css(".na-platform-row__name", text: "Crunchyroll")
  end

  it "shows the logo of the platform" do
    render_row

    expect(page).to have_css("img.na-platform-logo")
  end

  { "flatrate" => "Abonnement", "free" => "Gratuit", "ads" => "Gratuit avec publicité" }.each do |offer_type, label|
    it "says #{label.inspect} for a #{offer_type} offer" do
      render_row(offer_type: offer_type)

      expect(page).to have_css(".na-platform-row__offer", exact_text: label)
    end
  end

  context "when the address of the anime on the platform is known" do
    before { render_row }

    it "is a link to it that opens a new tab safely" do
      expect(page).to have_css("a.na-platform-row[href='#{address}'][target='_blank'][rel='noopener noreferrer']")
    end

    it "tells screen readers that the link opens a new tab" do
      expect(page).to have_css("a .visually-hidden", text: "(s'ouvre dans un nouvel onglet)")
    end

    it "shows an arrow, hidden from screen readers" do
      expect(page).to have_css("i.bi-arrow-up-right[aria-hidden='true']")
    end
  end

  context "when there is no address" do
    before { render_row(url: nil) }

    it "is not a link" do
      expect(page).to have_css("div.na-platform-row")
      expect(page).to have_no_css("a")
    end

    it "has no arrow" do
      expect(page).to have_no_css("i.bi-arrow-up-right")
    end
  end

  it "is not a link when the address is not a web address" do
    render_row(url: "javascript:alert(1)")

    expect(page).to have_no_css("a")
  end
end
