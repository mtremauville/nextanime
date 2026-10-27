require "rails_helper"

RSpec.describe Organisms::SignInFormComponent, type: :component do
  let(:resource) { User.new(email: "mika@example.com", password: "secret-value-123") }

  before { render_inline(described_class.new(resource: resource)) }

  it "posts to the sign in route" do
    expect(page).to have_css("form[action='/users/sign_in'][method='post']")
  end

  it "prefills the e-mail address" do
    expect(page).to have_field("Adresse e-mail", type: "email", with: "mika@example.com")
  end

  it "never prefills the password" do
    expect(page).to have_field("Mot de passe", type: "password")
    expect(page).to have_no_css("input[type='password'][value]")
  end

  it "submits the fields under the user scope" do
    expect(page).to have_css("input[name='user[email]']")
    expect(page).to have_css("input[name='user[password]']")
    expect(page).to have_css("input[type='checkbox'][name='user[remember_me]']")
  end

  it "helps the browser autofill" do
    expect(page).to have_css("input[name='user[email]'][autocomplete='email']")
    expect(page).to have_css("input[name='user[password]'][autocomplete='current-password']")
  end

  it "offers to remember the user" do
    expect(page).to have_unchecked_field("Se souvenir de moi")
  end

  it "links to the password reset" do
    expect(page).to have_link("Mot de passe oublié ?", href: "/users/password/new")
  end

  it "submits with a full-width primary button" do
    expect(page).to have_css("button.btn-na-primary.w-100[type='submit']", text: "Se connecter")
  end

  describe "after a failed attempt" do
    before do
      render_inline(described_class.new(resource: User.new(email: "ayako@example.com"), failed: true))
    end

    it "flags the password field" do
      expect(page.find_field("Mot de passe", exact: true)["aria-invalid"]).to eq("true")
    end

    it "leaves the e-mail field unflagged" do
      expect(page.find_field("Adresse e-mail")["aria-invalid"]).to be_nil
    end
  end
end
