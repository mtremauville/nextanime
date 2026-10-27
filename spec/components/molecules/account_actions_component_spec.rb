require "rails_helper"

RSpec.describe Molecules::AccountActionsComponent, type: :component do
  context "without a user" do
    before { render_inline(described_class.new) }

    it "links to the sign in page as a plain text link" do
      expect(page).to have_css("a.na-account__link[href='/users/sign_in']", text: "Connexion")
      expect(page).to have_no_css("a.btn[href='/users/sign_in']")
    end

    it "links to the sign up page as an outline button" do
      expect(page).to have_css("a.btn-na-outline[href='/users/sign_up']", text: "Créer un compte")
    end

    it "offers no sign out" do
      expect(page).to have_no_button("Déconnexion")
    end
  end

  context "with a user" do
    before { render_inline(described_class.new(user: build_stubbed(:user, email: "mickael@example.com"))) }

    it "shows the avatar with the initial of the e-mail address" do
      expect(page).to have_css("span.na-avatar", text: "M")
    end

    it "tells assistive technologies who is signed in" do
      expect(page).to have_css(".visually-hidden", text: "Connecté en tant que mickael@example.com")
    end

    it "signs out with a DELETE request" do
      expect(page).to have_css("form[action='/users/sign_out'][method='post']")
      expect(page).to have_css("input[name='_method'][value='delete']", visible: :all)
      expect(page).to have_button("Déconnexion")
    end

    it "shows the sign out as a neutral button" do
      expect(page).to have_css("button.na-account__signout", text: "Déconnexion")
    end

    it "offers no sign in or sign up" do
      expect(page).to have_no_link("Connexion")
      expect(page).to have_no_link("Créer un compte")
    end
  end
end
