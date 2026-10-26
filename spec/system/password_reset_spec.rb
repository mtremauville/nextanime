require "rails_helper"

RSpec.describe "Password reset", type: :system do
  let!(:user) { create(:user, password: "old password is long enough") }
  let(:new_password) { "brand new password is long" }

  before { ActionMailer::Base.deliveries.clear }

  def reset_path_from_last_mail
    html = Capybara.string(ActionMailer::Base.deliveries.last.html_part.decoded)
    URI(html.find_link("Choisir un nouveau mot de passe")[:href]).request_uri
  end

  def ask_for_a_link(email)
    visit new_user_session_path
    click_on "Mot de passe oublié ?"
    fill_in "Adresse e-mail", with: email
    click_on "Envoyer le lien"
  end

  it "lets a visitor who forgot the password choose a new one and sign in" do
    ask_for_a_link(user.email)

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_text("tu vas recevoir un lien")

    visit reset_path_from_last_mail
    fill_in "Nouveau mot de passe", with: new_password, exact: true
    fill_in "Confirmer le nouveau mot de passe", with: new_password
    click_on "Changer mon mot de passe"

    expect(page).to have_current_path(root_path)
    expect(page).to have_text("Ton mot de passe a bien été changé")
    expect(page).to have_css("form[action='/users/sign_out']", minimum: 1)
  end

  it "gives the same answer for an unknown address and sends nothing" do
    ask_for_a_link("nobody@example.com")

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_text("tu vas recevoir un lien")
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it "refuses a link that was already used and offers a new one" do
    token = user.send_reset_password_instructions
    User.reset_password_by_token(
      reset_password_token: token,
      password: "another long password ok",
      password_confirmation: "another long password ok"
    )

    visit edit_user_password_path(reset_password_token: token)
    fill_in "Nouveau mot de passe", with: new_password, exact: true
    fill_in "Confirmer le nouveau mot de passe", with: new_password
    click_on "Changer mon mot de passe"

    expect(page).to have_css("[role='alert']")
    expect(page).to have_link("Demander un nouveau lien")
  end
end
