require "rails_helper"

RSpec.describe Organisms::ForgotPasswordFormComponent, type: :component do
  let(:resource) { User.new }

  before { render_inline(described_class.new(resource: resource)) }

  it "posts to the password reset route" do
    form = page.find("form")

    expect(form[:action]).to eq("/users/password")
    expect(form[:method]).to eq("post")
  end

  it "asks for the e-mail address under the user scope" do
    field = page.find_field("Adresse e-mail")

    expect(field[:type]).to eq("email")
    expect(field[:name]).to eq("user[email]")
  end

  it "helps the browser autofill and focuses the field" do
    field = page.find_field("Adresse e-mail")

    expect(field[:autocomplete]).to eq("email")
    expect(field[:autofocus]).to be_present
  end

  it "submits with a full-width primary button" do
    expect(page).to have_css("button.btn-na-primary.w-100", text: "Envoyer le lien")
  end

  it "links back to the sign in page" do
    expect(page).to have_link("Retour à la connexion", href: "/users/sign_in")
  end

  context "with an e-mail address already typed" do
    let(:resource) { User.new(email: "ayako@example.com") }

    it "prefills the e-mail address" do
      expect(page.find_field("Adresse e-mail").value).to eq("ayako@example.com")
    end
  end
end
