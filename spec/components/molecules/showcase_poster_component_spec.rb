require "rails_helper"

RSpec.describe Molecules::ShowcasePosterComponent, type: :component do
  def render_poster(**overrides)
    render_inline(described_class.new(title: "Perfect Blue", position: :left, gradient: :violet, **overrides))
  end

  it "renders the title" do
    render_poster

    expect(page).to have_css(".na-showcase-poster__title", text: "Perfect Blue")
  end

  it "uses the given position and gradient" do
    render_poster(position: :right, gradient: :cyan)

    expect(page).to have_css(".na-showcase-poster.na-showcase-poster--right.na-showcase-poster--cyan")
  end

  it "raises for an unknown position" do
    expect { render_poster(position: :top) }.to raise_error(ArgumentError)
  end

  it "raises for an unknown gradient" do
    expect { render_poster(gradient: :green) }.to raise_error(ArgumentError)
  end
  context "with a cover" do
    before do
      render_inline(described_class.new(title: "Perfect Blue", position: :left, gradient: :violet, image_url: "https://img.test/perfect-blue.jpg"))
    end

    it "shows the cover, which only decorates" do
      expect(page).to have_css("img.na-showcase-poster__image[src='https://img.test/perfect-blue.jpg'][alt='']")
    end

    it "lets the browser load the cover when it is needed, the showcase being hidden on small screens" do
      expect(page).to have_css("img.na-showcase-poster__image[loading='lazy']")
    end

    it "keeps the title over the cover" do
      expect(page).to have_css(".na-showcase-poster__title", text: "Perfect Blue")
    end
  end

  context "without a cover" do
    it "keeps the gradient and shows no image" do
      render_inline(described_class.new(title: "Perfect Blue", position: :left, gradient: :violet))

      expect(page).to have_no_css("img")
    end
  end
end
