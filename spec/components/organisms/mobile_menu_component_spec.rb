require "rails_helper"

RSpec.describe Organisms::MobileMenuComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(items: items, countries: countries, selected_country: "FR", user: user))
  end

  let(:items) do
    [
      { label: "Découvrir", href: "/", icon: "stars", current: false },
      { label: "Catalogue", href: "/catalogue", icon: "grid", current: true }
    ]
  end
  let(:countries) { { "FR" => "France", "BE" => "Belgique" } }
  let(:user) { nil }

  it "renders a dialog labelled by its title" do
    expect(rendered).to have_css("dialog#mobile-menu[aria-labelledby='mobile-menu-title']")
    expect(rendered).to have_css("#mobile-menu-title", text: "Menu")
  end

  it "offers a button that closes the menu" do
    expect(rendered).to have_css("button[aria-label='Fermer le menu'][data-action*='menu#close']")
  end
  it "connects the dialog to the menu controller" do
    expect(rendered).to have_css("dialog[data-menu-target='dialog'][data-action*='click->menu#backdrop'][data-action*='close->menu#closed']")
  end
  it "links every page of the navigation" do
    expect(rendered).to have_link("Découvrir", href: "/")
    expect(rendered).to have_link("Catalogue", href: "/catalogue")
  end

  it "marks the current page" do
    expect(rendered).to have_css("nav[aria-label='Navigation mobile'] a[aria-current='page']", count: 1, text: "Catalogue")
  end

  it "offers one switch between the dark and the light theme" do
    expect(rendered).to have_css("fieldset legend", text: "Thème")
    expect(rendered).to have_css("button[role='switch'][aria-checked='true'][data-controller='theme'][data-action='theme#toggle']", text: "Mode sombre")
    expect(rendered).to have_no_css("button[data-theme-theme-param]")
  end

  describe "account" do
    let(:menu_arguments) { { items: [], countries: { "FR" => "France" }, selected_country: "FR" } }

    context "for a visitor" do
      before { render_inline(described_class.new(**menu_arguments)) }

      it "announces the guest mode" do
        expect(page).to have_css(".na-menu__guest", text: "Mode invité")
        expect(page).to have_text("Ton profil est gardé sur cet appareil. Crée un compte pour le retrouver partout.")
      end

      it "offers to create an account and to sign in" do
        expect(page).to have_css("a.btn-na-primary[href='/users/sign_up']", text: "Créer un compte")
        expect(page).to have_css("a.btn-na-outline[href='/users/sign_in']", text: "Connexion")
      end

      it "offers no sign out" do
        expect(page).to have_no_button("Déconnexion")
      end
    end

    context "for a signed in user" do
      before do
        render_inline(described_class.new(**menu_arguments, user: build_stubbed(:user, email: "mickael@example.com")))
      end

      it "shows who is signed in" do
        expect(page).to have_css(".na-menu__account span.na-avatar", text: "M")
        expect(page).to have_css(".na-menu__account", text: "mickael@example.com")
      end

      it "asks to confirm before signing out" do
        expect(page).to have_css("button.w-100[data-action='confirm-modal#open']", text: "Déconnexion")
        expect(page).to have_css("dialog#signout-menu h2#signout-menu-title", text: "Se déconnecter ?")
      end

      it "signs out with a DELETE request once confirmed" do
        expect(page).to have_css("dialog#signout-menu form[action='/users/sign_out'][method='post']")
        expect(page).to have_css("dialog#signout-menu input[name='_method'][value='delete']", visible: :all)
        expect(page).to have_css("dialog#signout-menu button[type='submit']", text: "Se déconnecter")
      end

      it "shows neither the guest notice nor the sign in links" do
        expect(page).to have_no_css(".na-menu__guest")
        expect(page).to have_no_link("Connexion")
      end
    end
  end

  describe "profile link" do
    def render_menu(user: nil)
      render_inline(described_class.new(items: [], countries: { "FR" => "France" }, selected_country: "FR", user: user))
    end

    it "leads a signed in user to the profile page" do
      render_menu(user: build_stubbed(:user))

      expect(page).to have_link("Mon profil", href: "/profil")
    end

    it "offers no profile to a visitor" do
      render_menu

      expect(page).to have_no_link("Mon profil")
    end
  end
  describe "country choice" do
    context "for a member" do
      let(:user) { build_stubbed(:user) }

      it "lists the countries in a labelled drop-down list" do
        expect(rendered).to have_select("Pays", options: [ "France", "Belgique" ])
      end

      it "selects the given country" do
        expect(rendered).to have_select("Pays", selected: "France")
      end

      it "sends the choice to the country of the member" do
        expect(rendered).to have_css("form[action='/country'] select#menu-country")
        expect(rendered).to have_css("form input[name='_method'][value='patch']", visible: :all)
      end

      it "names the choice country, as the selector of the header does" do
        expect(rendered).to have_css("select[name='country'] option[value='BE']", text: "Belgique")
      end

      it "sends the form as soon as the choice changes" do
        expect(rendered).to have_css("form[data-controller='auto-submit'][data-action='change->auto-submit#submit']")
      end

      it "keeps a button for the members without JavaScript" do
        expect(rendered).to have_button("Changer de pays", visible: :all)
      end
    end

    context "for a visitor" do
      it "offers no choice of country" do
        expect(rendered).to have_no_select("Pays")
        expect(rendered).to have_no_css("form[action='/country']")
      end
    end
  end
end
