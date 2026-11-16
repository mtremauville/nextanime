require "rails_helper"

RSpec.describe Molecules::PlatformLineComponent, type: :component do
  def render_line(*names)
    platforms = names.map { |name| build_stubbed(:streaming_platform, name: name) }
    render_inline(described_class.new(platforms: platforms))
  end

  it "renders nothing when no platform is known" do
    render_line

    expect(page).to have_no_css(".na-platform-line")
  end

  it "names the best platform after a lead word" do
    render_line("Crunchyroll", "Netflix")

    expect(page).to have_css(".na-platform-line__lead", text: "Sur")
    expect(page).to have_css(".na-platform-line__name", text: "Crunchyroll")
  end

  it "shows the small logo of the best platform only" do
    render_line("Crunchyroll", "Netflix")

    expect(page).to have_css(".na-platform-line .na-platform-logo--small", count: 1)
  end

  it "counts the other platforms" do
    render_line("Crunchyroll", "Netflix", "Prime Video")

    expect(page).to have_css(".na-platform-line__more", text: "et 2 autres")
  end

  it "uses the singular for a single other platform" do
    render_line("Crunchyroll", "Netflix")

    expect(page).to have_css(".na-platform-line__more", text: "et 1 autre")
    expect(page).to have_no_css(".na-platform-line__more", text: "autres")
  end

  it "shows no count when there is only one platform" do
    render_line("Crunchyroll")

    expect(page).to have_no_css(".na-platform-line__more")
  end

  it "names the other platforms for screen readers" do
    render_line("Crunchyroll", "Netflix", "Prime Video")

    expect(page).to have_css(".na-platform-line .visually-hidden", text: "Netflix, Prime Video", visible: :all)
  end
end
