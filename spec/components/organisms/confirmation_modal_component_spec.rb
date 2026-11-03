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

RSpec.describe Organisms::ConfirmationModalComponent, "by default", type: :component do
  before { render_inline(described_class.new(id: "x", title: "T", confirm_label: "OK", confirm_url: "/x")) }

  it "offers no trigger" do
    expect(page).to have_no_css("button[data-action='confirm-modal#open']")
  end

  it "asks nothing to type and leaves the confirmation enabled" do
    expect(page).to have_no_css("input[type='text']")
    expect(page).to have_no_css("button[disabled]")
  end

  it "colors the icon magenta" do
    expect(page).to have_css(".na-modal__icon.na-modal__icon--magenta")
  end
end

RSpec.describe Organisms::ConfirmationModalComponent, "with a trigger", type: :component do
  before do
    render_inline(described_class.new(id: "x", title: "T", confirm_label: "OK", confirm_url: "/x", trigger_label: "Réinitialiser mon profil"))
  end

  it "offers a button that opens the dialog" do
    expect(page).to have_css("button.btn-na-outline[data-action='confirm-modal#open']", text: "Réinitialiser mon profil")
  end

  it "keeps the trigger outside of the dialog" do
    expect(page).to have_no_css("dialog button[data-action='confirm-modal#open']")
  end
end

RSpec.describe Organisms::ConfirmationModalComponent, "tone", type: :component do
  it "supports a cyan icon" do
    render_inline(described_class.new(id: "x", title: "T", confirm_label: "OK", confirm_url: "/x", tone: :cyan))

    expect(page).to have_css(".na-modal__icon.na-modal__icon--cyan")
  end

  it "raises for an unknown tone" do
    expect { described_class.new(id: "x", title: "T", confirm_label: "OK", confirm_url: "/x", tone: :green) }
      .to raise_error(ArgumentError, /tone/i)
  end
end

RSpec.describe Organisms::ConfirmationModalComponent, "with a word to type", type: :component do
  before do
    render_inline(described_class.new(id: "delete-account", title: "T", confirm_label: "Supprimer définitivement",
                                      confirm_url: "/x", confirmation_word: "SUPPRIMER"))
  end

  it "asks to type the word" do
    expect(page).to have_css("label[for='delete-account-confirm']", text: "SUPPRIMER")
  end

  it "offers a field for it that the controller listens to" do
    expect(page).to have_css("input#delete-account-confirm[type='text'][autocomplete='off']" \
                             "[data-confirm-modal-target='word'][data-action='input->confirm-modal#check']")
  end

  it "keeps the confirmation disabled until the word is typed" do
    expect(page).to have_css("button[disabled][aria-disabled='true'][data-confirm-modal-target='confirm']", text: "Supprimer définitivement")
  end

  it "tells the controller which word to expect" do
    expect(page).to have_css("[data-controller='confirm-modal'][data-confirm-modal-word-value='SUPPRIMER']")
  end
end
