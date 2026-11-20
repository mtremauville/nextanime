require "rails_helper"

RSpec.describe Organisms::DataCardComponent, type: :component do
  subject(:card) do
    render_inline(described_class.new(export_href: "/profil/export", delete_href: "/users"))
    page
  end

  it "is a section named by its heading" do
    expect(card).to have_css("section.na-data-card[aria-labelledby='data-card-title']")
  end

  it "introduces the card with a heading" do
    expect(card).to have_css("h2#data-card-title", text: "Mes données")
  end

  it "reminds that the data can be taken away at any time" do
    expect(card).to have_text("Tu peux récupérer tes données ou supprimer ton compte à tout moment.")
  end

  it "says what the file holds" do
    expect(card).to have_text("compte, tes swipes et ta watchlist")
  end

  it "offers the export as a link to the export" do
    expect(card).to have_link("Exporter mes données", href: "/profil/export")
  end

  it "bypasses Turbo so that the browser downloads the file" do
    expect(card).to have_css("a[href='/profil/export'][data-turbo='false']")
  end

  describe "account deletion" do
    it "offers a button that opens the deletion dialog" do
      expect(card).to have_button("Supprimer mon compte")
    end

    it "asks for a confirmation in a dialog named after the action" do
      expect(card).to have_css("dialog#delete-account h2", text: "Supprimer mon compte ?")
    end

    it "lists what is erased" do
      expect(card).to have_css("dialog#delete-account", text: "ton profil de goûts, tes swipes et ta watchlist")
    end

    it "asks to type SUPPRIMER before confirming" do
      expect(card).to have_css("[data-confirm-modal-word-value='SUPPRIMER'] dialog#delete-account")
    end

    it "keeps the confirmation locked until the word is typed" do
      expect(card).to have_button("Supprimer définitivement", disabled: true)
    end

    it "sends the confirmation as a DELETE to the deletion address" do
      expect(card).to have_css("dialog#delete-account form[action='/users'] input[name='_method'][value='delete']", visible: :all)
    end
  end

  it "styles the deletion trigger as a destructive action" do
    expect(card).to have_css("button.btn-na-danger", text: "Supprimer mon compte")
  end
end
