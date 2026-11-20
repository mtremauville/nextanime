require "rails_helper"

RSpec.describe Molecules::PlatformBadgesComponent, type: :component do
  def platforms(count)
    Array.new(count) do |index|
      build_stubbed(:streaming_platform, name: "Platform #{index + 1}", slug: "platform-#{index + 1}", logo_path: nil)
    end
  end

  it "shows a small logo for each platform" do
    render_inline(described_class.new(platforms: platforms(2)))

    expect(page).to have_css(".na-platform-badges .na-platform-logo--small", count: 2)
  end

  it "shows three logos at most and counts the platforms that are left out" do
    render_inline(described_class.new(platforms: platforms(5)))

    expect(page).to have_css(".na-platform-logo--small", count: 3)
    expect(page).to have_css(".na-platform-badges__more", text: "+2")
  end

  it "counts nothing when every platform is shown" do
    render_inline(described_class.new(platforms: platforms(3)))

    expect(page).to have_no_css(".na-platform-badges__more")
  end

  it "can show another number of logos" do
    render_inline(described_class.new(platforms: platforms(3), max: 2))

    expect(page).to have_css(".na-platform-logo--small", count: 2)
    expect(page).to have_css(".na-platform-badges__more", text: "+1")
  end

  it "lists every platform for screen readers, and hides the count that is only visual" do
    render_inline(described_class.new(platforms: platforms(5)))

    expect(page).to have_css(".visually-hidden", text: "Disponible sur Platform 1, Platform 2, Platform 3, Platform 4, Platform 5")
    expect(page).to have_css(".na-platform-badges__more[aria-hidden='true']")
  end

  it "shows nothing when no platform is known: the anime is not known to be unavailable" do
    render_inline(described_class.new(platforms: []))

    expect(page).to have_no_css(".na-platform-badges")
    expect(rendered_content).to be_blank
  end
end
