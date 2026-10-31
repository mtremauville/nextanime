require "rails_helper"

RSpec.describe "Styleguide confirmation modals", type: :request do
  let(:page) { Capybara.string(response.body) }

  before { get styleguide_path }

  it "has its own section" do
    expect(page).to have_css("h2", text: "Modals de confirmation")
  end

  it "offers a trigger for each modal" do
    expect(page).to have_css("button[data-action='confirm-modal#open']", count: 3)
  end

  describe "profile reset" do
    it "asks for confirmation with a cyan icon" do
      expect(page).to have_css("dialog#reset-profile .na-modal__icon--cyan")
      expect(page).to have_css("dialog#reset-profile h2", text: "Réinitialiser ton profil de goûts ?")
    end

    it "keeps the watchlist and the account out of it" do
      expect(page).to have_css("dialog#reset-profile", text: "Ta watchlist et ton compte ne changent pas.")
    end
  end

  describe "account deletion" do
    it "asks for confirmation with a magenta icon" do
      expect(page).to have_css("dialog#delete-account .na-modal__icon--magenta")
      expect(page).to have_css("dialog#delete-account h2", text: "Supprimer ton compte ?")
    end

    it "lists what is erased" do
      expect(page).to have_css("dialog#delete-account li", minimum: 2)
    end

    it "asks to type SUPPRIMER before confirming" do
      expect(page).to have_css("[data-confirm-modal-word-value='SUPPRIMER'] dialog#delete-account")
      expect(page).to have_css("dialog#delete-account button[disabled]", text: "Supprimer définitivement")
    end
  end

  describe "watchlist removal" do
    it "names the anime to remove" do
      expect(page).to have_css("dialog#remove-watchlist h2", text: "Retirer Frieren de ta watchlist ?")
    end

    it "needs no word to type" do
      expect(page).to have_no_css("dialog#remove-watchlist input[type='text']")
    end
  end
end
