require "rails_helper"

RSpec.describe Molecules::AlertComponent, type: :component do
  it "renders the message" do
    render_inline(described_class.new(message: "Bienvenue"))

    expect(page).to have_text("Bienvenue")
  end

  it "uses the notice variant by default" do
    render_inline(described_class.new(message: "Bienvenue"))

    expect(page).to have_css("div.na-alert.na-alert--success[role='status']")
  end

  it "announces an alert politely but firmly" do
    render_inline(described_class.new(message: "Erreur", variant: :alert))

    expect(page).to have_css("div.na-alert.na-alert--danger[role='alert']")
  end

  it "hides the icon from assistive technologies" do
    render_inline(described_class.new(message: "Bienvenue"))

    expect(page).to have_css("i.bi[aria-hidden='true']")
  end

  it "raises for an unknown variant" do
    expect { described_class.new(message: "Info", variant: :info) }
      .to raise_error(ArgumentError, /Unknown alert variant/)
  end
end
