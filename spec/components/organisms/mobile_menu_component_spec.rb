require "rails_helper"

RSpec.describe Organisms::MobileMenuComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(items: items, countries: countries, selected_country: "FR"))
  end

  let(:items) do
    [
      { label: "Découvrir", href: "/", icon: "stars", current: false },
      { label: "Catalogue", href: "/catalogue", icon: "grid", current: true }
    ]
  end
  let(:countries) { { "FR" => "France", "BE" => "Belgique" } }

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

  it "lists the countries in a labelled group" do
    expect(rendered).to have_css("fieldset legend", text: "Pays")
    expect(rendered).to have_field("Belgique", type: "radio", checked: false)
  end

  it "selects the given country" do
    expect(rendered).to have_field("France", type: "radio", checked: true)
  end

  it "offers the dark and light themes" do
    expect(rendered).to have_css("fieldset legend", text: "Thème")
    expect(rendered).to have_css("button[data-theme-theme-param='dark']", text: "Sombre")
    expect(rendered).to have_css("button[data-theme-theme-param='light']", text: "Clair")
  end

  describe "account" do
    let(:menu_arguments) { { items: [], countries: { "FR" => "France" }, selected_country: "FR" } }

    context "for a visitor" do
      before { render_inline(described_class.new(**menu_arguments)) }

      it "announces the guest mode" do
        expect(page).to have_css(".na-menu__guest", text: "Mode invité")
        expect(page).to have_text("Ton profil n'est pas sauvegardé : il disparaît si tu fermes la page.")
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

      it "signs out with a DELETE request" do
        expect(page).to have_css("form[action='/users/sign_out'][method='post']")
        expect(page).to have_css("input[name='_method'][value='delete']", visible: :all)
        expect(page).to have_button("Déconnexion")
      end

      it "shows neither the guest notice nor the sign in links" do
        expect(page).to have_no_css(".na-menu__guest")
        expect(page).to have_no_link("Connexion")
      end
    end
  end
end
