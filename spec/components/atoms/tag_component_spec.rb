require "rails_helper"

RSpec.describe Atoms::TagComponent, type: :component do
  it "renders its label" do
    render_inline(described_class.new(label: "Thriller"))

    expect(page).to have_css("span.na-tag", text: "Thriller")
  end

  it "uses the magenta tone by default" do
    render_inline(described_class.new(label: "Thriller"))

    expect(page).to have_no_css("span.na-tag--cyan")
  end

  it "supports the cyan tone" do
    render_inline(described_class.new(label: "Psychologique", tone: :cyan))

    expect(page).to have_css("span.na-tag.na-tag--cyan", text: "Psychologique")
  end

  it "raises for an unknown tone" do
    expect { described_class.new(label: "Thriller", tone: :green) }
      .to raise_error(ArgumentError, /Unknown tone/)
  end
end
