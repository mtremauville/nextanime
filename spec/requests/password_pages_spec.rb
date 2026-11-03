require "rails_helper"

RSpec.describe "Password reset pages", type: :request do
  def html
    Capybara.string(response.body)
  end

  describe "GET /users/password/new" do
    before { get new_user_password_path }

    it "succeeds" do
      expect(response).to have_http_status(:ok)
    end

    it "invites the visitor to ask for a link" do
      expect(html).to have_css("h1", text: "Mot de passe oublié ?")
    end

    it "tells how long the link stays valid" do
      expect(html).to have_text("environ 2 heures")
    end

    it "asks for the e-mail address" do
      expect(html).to have_field("Adresse e-mail", type: "email")
    end

    it "uses the authentication layout" do
      expect(html).to have_css(".na-auth")
    end
  end

  describe "GET /users/password/edit" do
    it "asks for the new password when a token is given" do
      get edit_user_password_path(reset_password_token: "abc123")

      expect(response).to have_http_status(:ok)
      expect(html).to have_css("h1", text: "Nouveau mot de passe")
      expect(html).to have_field("Nouveau mot de passe", exact: true)
      expect(html.find("input[name='user[reset_password_token]']", visible: :all).value).to eq("abc123")
    end

    it "goes back to the sign in page without a token" do
      get edit_user_password_path

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "PATCH /users/password" do
    let!(:user) { create(:user) }
    let(:token) { user.send_reset_password_instructions }

    def update_password(token:, password:, confirmation: password)
      patch user_password_path, params: { user: {
        reset_password_token: token,
        password: password,
        password_confirmation: confirmation
      } }
    end

    it "explains why a too short password is refused and keeps the token" do
      update_password(token: token, password: "short")

      expect(response).to have_http_status(:unprocessable_content)
      expect(html).to have_text("trop court")
      expect(html.find("input[name='user[reset_password_token]']", visible: :all).value).to eq(token)
    end

    it "warns about an invalid link" do
      update_password(token: "not-a-token", password: "brand new password is long")

      expect(response).to have_http_status(:unprocessable_content)
      expect(html).to have_css("[role='alert']")
      expect(html).to have_link("Demander un nouveau lien", href: new_user_password_path)
    end
  end
end
