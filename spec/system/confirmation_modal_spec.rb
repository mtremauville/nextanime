require "rails_helper"

RSpec.describe "Confirmation modals", type: :system, js: true do
  before { visit styleguide_path }

  it "starts closed" do
    expect(page).to have_no_css("dialog[open]")
  end

  it "opens from its trigger with the focus on the safe action" do
    click_button "Retirer de la watchlist"

    expect(page).to have_css("dialog#remove-watchlist[open]")
    expect(page.evaluate_script("document.activeElement.textContent.trim()")).to eq "Annuler"
  end

  it "closes with the cancel button" do
    click_button "Retirer de la watchlist"
    within("dialog#remove-watchlist") { click_button "Annuler" }

    expect(page).to have_no_css("dialog[open]")
  end

  it "closes with the Escape key" do
    click_button "Retirer de la watchlist"
    page.send_keys(:escape)

    expect(page).to have_no_css("dialog[open]")
  end

  it "closes when the backdrop is clicked" do
    click_button "Retirer de la watchlist"
    page.execute_script("document.getElementById('remove-watchlist').click()")

    expect(page).to have_no_css("dialog[open]")
  end

  it "stays open when the panel is clicked" do
    click_button "Retirer de la watchlist"
    find("dialog#remove-watchlist h2").click

    expect(page).to have_css("dialog#remove-watchlist[open]")
  end

  describe "account deletion" do
    before { click_button "Supprimer mon compte" }

    it "keeps the confirmation locked until the word is typed" do
      expect(page).to have_button("Supprimer définitivement", disabled: true)
    end

    it "stays locked for a word that is not exactly the expected one" do
      fill_in "delete-account-confirm", with: "supprimer"

      expect(page).to have_button("Supprimer définitivement", disabled: true)
    end

    it "unlocks with the expected word" do
      fill_in "delete-account-confirm", with: "SUPPRIMER"

      expect(page).to have_button("Supprimer définitivement", disabled: false)
    end

    it "locks again when the word is erased" do
      fill_in "delete-account-confirm", with: "SUPPRIMER"
      fill_in "delete-account-confirm", with: "SUPPRIME"

      expect(page).to have_button("Supprimer définitivement", disabled: true)
    end
  end
end
