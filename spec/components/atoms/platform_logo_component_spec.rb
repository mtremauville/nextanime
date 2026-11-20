require "rails_helper"

RSpec.describe Atoms::PlatformLogoComponent, type: :component do
  def render_platform(**attributes)
    render_inline(described_class.new(platform: build_stubbed(:streaming_platform, **attributes)))
  end

  context "when the platform has a logo" do
    before { render_platform(logo_path: "/abc.png") }

    it "shows the logo from the image server of TMDB" do
      expect(page).to have_css("img.na-platform-logo[src='https://image.tmdb.org/t/p/w92/abc.png']")
    end

    it "is decorative, because the name of the platform is written next to it" do
      expect(page).to have_css("img[alt='']")
    end

    it "has a size, so that the page does not move when it loads" do
      expect(page).to have_css("img[width='44'][height='44'][loading='lazy']")
    end
  end

  context "when the platform has no logo" do
    it "shows the initials in place of the logo" do
      render_platform(name: "Crunchyroll", logo_path: nil)

      expect(page).to have_css("span.na-platform-logo--initials", text: "CR")
      expect(page).to have_no_css("img")
    end

    it "hides the initials from screen readers" do
      render_platform(name: "Crunchyroll", logo_path: nil)

      expect(page).to have_css("span[aria-hidden='true']")
    end

    it "takes the first letter of each word" do
      render_platform(name: "Pluto TV", logo_path: nil)

      expect(page).to have_css("span.na-platform-logo--initials", text: "PT")
    end

    it "keeps three letters at most" do
      render_platform(name: "Animation Digital Network Plus", logo_path: nil)

      expect(page).to have_css("span.na-platform-logo--initials", text: "ADN")
    end
  end
  describe "the size of the logo" do
    def render_sized(size, **attributes)
      render_inline(described_class.new(platform: build_stubbed(:streaming_platform, **attributes), size: size))
    end

    it "is the regular size unless a size is asked for" do
      render_platform(logo_path: "/abc.png")

      expect(page).to have_no_css(".na-platform-logo--small")
    end

    it "can be small, for the badges of the cards" do
      render_sized(:small, logo_path: "/abc.png")

      expect(page).to have_css("img.na-platform-logo--small[width='24'][height='24']")
    end

    it "makes the initials small too" do
      render_sized(:small, name: "Crunchyroll", logo_path: nil)

      expect(page).to have_css("span.na-platform-logo--initials.na-platform-logo--small", text: "CR")
    end

    it "refuses a size that does not exist" do
      expect { render_sized(:huge) }.to raise_error(ArgumentError, /Unknown size/)
    end
  end
end
