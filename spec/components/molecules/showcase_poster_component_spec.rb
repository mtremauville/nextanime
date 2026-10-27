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
end
