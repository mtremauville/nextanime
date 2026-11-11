require "rails_helper"

RSpec.describe Organisms::WatchlistRemovalComponent, type: :component do
  let(:anime) { create(:anime, title_romaji: "Sousou no Frieren", title_english: "Frieren", episodes: 28) }
  let(:entry) { create(:watchlist_entry, :watching, progress: 14, anime: anime) }

  def removal(status: nil)
    render_inline(described_class.new(entry: entry, status: status))
  end

  it "opens the confirmation from a button" do
    removal

    expect(page).to have_css("button[data-action='confirm-modal#open']", text: "Retirer")
  end

  it "gives each entry its own dialog" do
    removal

    expect(page).to have_css("dialog#remove-entry-#{entry.id}")
  end

  it "asks about the anime by its displayed title" do
    removal

    expect(page).to have_css("dialog h2", text: "Retirer Frieren de ta watchlist ?")
  end

  it "uses the trash icon" do
    removal

    expect(page).to have_css("dialog .na-modal__icon .bi-trash")
  end

  it "warns that the progress will be lost" do
    removal

    expect(page).to have_css("dialog .na-modal__body", text: "Ta progression (épisode 14 sur 28) sera perdue.")
    expect(page).to have_css("dialog .na-modal__body", text: "Tu pourras le rajouter plus tard depuis les recommandations.")
  end

  it "warns about the episode only when the number of episodes is unknown" do
    anime.update!(episodes: nil)

    removal

    expect(page).to have_css("dialog .na-modal__body", text: "Ta progression (épisode 14) sera perdue.")
  end

  it "does not warn about a progress that does not exist" do
    entry.update!(progress: 0, status: "plan_to_watch")

    removal

    expect(page).to have_no_text("Ta progression")
    expect(page).to have_css("dialog .na-modal__body", text: "Tu pourras le rajouter plus tard depuis les recommandations.")
  end

  it "removes the entry with a DELETE request" do
    removal

    expect(page).to have_css("dialog form[action='/watchlist/#{entry.id}']", text: "Retirer")
    expect(page).to have_css("dialog form input[name='_method'][value='delete']", visible: :all)
  end

  it "keeps the status filter in the request" do
    removal(status: "watching")

    expect(page).to have_css("dialog form[action='/watchlist/#{entry.id}?status=watching']")
  end
end
