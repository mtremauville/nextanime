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

  describe "profile link" do
    let(:user) { build_stubbed(:user, email: "mickael@example.com") }

    it "leads a signed in user to the profile page with the avatar and a label" do
      render_inline(described_class.new(user: user))

      expect(page).to have_css("a.na-account__profile[href='/profil']", text: "Mon profil")
      expect(page).to have_css("a.na-account__profile span.na-avatar")
    end

    it "is not marked as current on other pages" do
      render_inline(described_class.new(user: user))

      expect(page).to have_no_css("a.na-account__profile[aria-current]")
    end

    it "is marked as the current page on the profile page" do
      with_request_url("/profil") { render_inline(described_class.new(user: user)) }

      expect(page).to have_css("a.na-account__profile[aria-current='page']")
    end

    it "is not offered to a visitor" do
      render_inline(described_class.new)

      expect(page).to have_no_link("Mon profil")
    end
  end
end
