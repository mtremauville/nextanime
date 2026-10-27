require "rails_helper"

RSpec.describe "Authentication headings", type: :request do
  let(:document) { Capybara.string(response.body) }

  def expect_heading(title:, subtitle:)
    expect(document).to have_css("h1.na-auth-heading__title", text: title)
    expect(document).to have_css("p.na-auth-heading__subtitle", text: subtitle)
  end

  it "introduces the sign in page" do
    get new_user_session_path

    expect_heading(title: "Content de te revoir", subtitle: "Retrouve ton profil de goûts")
  end

  it "introduces the sign up page" do
    get new_user_registration_path

    expect_heading(title: "Rejoins NextAnime", subtitle: "Sauvegarde ton profil de goûts")
  end

  it "introduces the forgotten password page" do
    get new_user_password_path

    expect_heading(title: "Mot de passe oublié ?", subtitle: "Indique ton adresse e-mail")
  end

  it "introduces the new password page" do
    get edit_user_password_path(reset_password_token: "a-token")

    expect_heading(title: "Nouveau mot de passe", subtitle: "Choisis un mot de passe solide")
  end
end
