require "rails_helper"

RSpec.describe Organisms::ConfirmationModalComponent, type: :component do
  let(:arguments) do
    {
      id: "reset-profile",
      title: "Réinitialiser ton profil de goûts ?",
      confirm_label: "Réinitialiser",
      confirm_url: "/profile/reset"
    }
  end

  before do
    render_inline(described_class.new(**arguments)) { "Tes swipes seront effacés." }
  end

  it "is a modal dialog labelled by its title" do
    expect(page).to have_css("dialog#reset-profile.na-modal[aria-labelledby='reset-profile-title']")
    expect(page).to have_css("h2#reset-profile-title", text: "Réinitialiser ton profil de goûts ?")
  end

  it "shows the given content" do
    expect(page).to have_css(".na-modal__body", text: "Tes swipes seront effacés.")
  end

  it "hides the icon from assistive technologies" do
    expect(page).to have_css(".na-modal__icon[aria-hidden='true']")
  end

  it "starts the focus on the safe action, which closes the dialog" do
    expect(page).to have_css("button.btn-na-outline[autofocus][data-action='confirm-modal#close']", text: "Annuler")
  end

  it "confirms with a form sent to the given address" do
    expect(page).to have_css("form[action='/profile/reset'] button.btn-na-primary[type='submit']", text: "Réinitialiser")
  end

  it "sends the confirmation with a DELETE request by default" do
    expect(page).to have_css("form[action='/profile/reset'] input[name='_method'][value='delete']", visible: :all)
  end

  it "is driven by the confirm modal Stimulus controller" do
    expect(page).to have_css("[data-controller='confirm-modal'] dialog[data-confirm-modal-target='dialog']")
    expect(page).to have_css("dialog[data-action='click->confirm-modal#backdrop']")
  end
end

RSpec.describe Organisms::ConfirmationModalComponent, "with another request method", type: :component do
  it "uses it for the confirmation" do
    render_inline(described_class.new(id: "x", title: "T", confirm_label: "OK", confirm_url: "/x", confirm_method: :post))

    expect(page).to have_no_css("input[name='_method']", visible: :all)
  end
end
