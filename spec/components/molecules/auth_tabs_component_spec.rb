require "rails_helper"

RSpec.describe Molecules::AuthTabsComponent, type: :component do
  it "renders a labelled navigation with both tabs" do
    render_inline(described_class.new(current: :sign_in))

    expect(page).to have_css("nav[aria-label='Connexion ou inscription']")
    expect(page).to have_link("Connexion", href: "/users/sign_in")
    expect(page).to have_link("Créer un compte", href: "/users/sign_up")
  end

  it "marks only the sign in tab as current" do
    render_inline(described_class.new(current: :sign_in))

    expect(page).to have_css("a[aria-current='page']", text: "Connexion", count: 1)
    expect(page).to have_no_css("a[aria-current='page']", text: "Créer un compte")
  end

  it "marks only the sign up tab as current" do
    render_inline(described_class.new(current: :sign_up))

    expect(page).to have_css("a[aria-current='page']", text: "Créer un compte", count: 1)
    expect(page).to have_no_css("a[aria-current='page']", text: "Connexion")
  end

  it "uses the active class on the current tab only" do
    render_inline(described_class.new(current: :sign_in))

    expect(page).to have_css("a.na-auth-tabs__link--active", count: 1, text: "Connexion")
  end

  it "raises for an unknown tab" do
    expect { described_class.new(current: :profile) }.to raise_error(ArgumentError, /Unknown tab/)
  end
end
