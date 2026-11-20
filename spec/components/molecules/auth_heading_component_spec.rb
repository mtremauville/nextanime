require "rails_helper"

RSpec.describe Molecules::AuthHeadingComponent, type: :component do
  it "renders the title as the main heading" do
    render_inline(described_class.new(title: "Content de te revoir"))

    expect(page).to have_css("h1.na-auth-heading__title", text: "Content de te revoir")
  end

  it "renders the subtitle under the title" do
    render_inline(described_class.new(title: "Rejoins NextAnime", subtitle: "Sauvegarde ton profil."))

    expect(page).to have_css("p.na-auth-heading__subtitle", text: "Sauvegarde ton profil.")
  end

  it "has no subtitle markup without a subtitle" do
    render_inline(described_class.new(title: "Rejoins NextAnime"))

    expect(page).to have_no_css(".na-auth-heading__subtitle")
  end
end
