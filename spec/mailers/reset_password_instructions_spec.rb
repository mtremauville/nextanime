require "rails_helper"

RSpec.describe "Reset password e-mail", type: :mailer do
  let(:user) { create(:user) }
  let(:mail) { Devise::Mailer.reset_password_instructions(user, "abc123") }
  let(:body) { Capybara.string(mail.body.decoded) }

  it "has a subject that says what it is for" do
    expect(mail.subject).to eq("Réinitialise ton mot de passe NextAnime")
  end

  it "speaks to the user informally" do
    expect(body).to have_text("Tu as demandé")
  end

  it "offers a clearly labelled link carrying the token" do
    expect(body).to have_link(
      "Choisir un nouveau mot de passe",
      href: %r{/users/password/edit\?reset_password_token=abc123}
    )
  end

  it "tells how long the link stays valid" do
    expect(body).to have_text("environ 2 heures")
  end

  it "reassures someone who did not ask for it" do
    expect(body).to have_text("ignore simplement cet e-mail")
  end
end
