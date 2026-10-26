require "rails_helper"

RSpec.describe "Password reset messages", type: :request do
  let!(:user) { create(:user) }

  it "reassures neutrally after a link was asked for" do
    post user_password_path, params: { user: { email: "nobody@example.com" } }

    expect(flash[:notice]).to eq(
      "Si ton adresse e-mail est connue, tu vas recevoir un lien pour choisir un nouveau mot de passe."
    )
  end

  it "confirms the change of password" do
    token = user.send_reset_password_instructions

    patch user_password_path, params: { user: {
      reset_password_token: token,
      password: "brand new password is long",
      password_confirmation: "brand new password is long"
    } }

    expect(flash[:notice]).to eq("Ton mot de passe a bien été changé. Tu es connecté.")
  end

  it "explains what to do when the link carries no token" do
    get edit_user_password_path

    expect(flash[:alert]).to eq("Ce lien n'est pas valide. Demande-en un nouveau.")
  end
end
