require "rails_helper"

RSpec.describe Organisms::ResetPasswordFormComponent, type: :component do
  let(:resource) { User.new(reset_password_token: "abc123") }

  before { render_inline(described_class.new(resource: resource)) }

  it "sends the new password with a PATCH request" do
    form = page.find("form")

    expect(form[:action]).to eq("/users/password")
    expect(form.find("input[name='_method']", visible: :all).value).to eq("patch")
  end

  it "carries the reset token in a hidden field" do
    token = page.find("input[name='user[reset_password_token]']", visible: :all)

    expect(token.value).to eq("abc123")
  end

  it "asks for the new password and its confirmation" do
    expect(page.find_field("Nouveau mot de passe", exact: true)[:name]).to eq("user[password]")
    expect(page.find_field("Confirmer le nouveau mot de passe")[:name]).to eq("user[password_confirmation]")
  end

  it "helps the browser suggest a new password" do
    expect(page.find_field("Nouveau mot de passe", exact: true)[:autocomplete]).to eq("new-password")
    expect(page.find_field("Confirmer le nouveau mot de passe")[:autocomplete]).to eq("new-password")
  end

  it "reminds the minimum password length" do
    expect(page).to have_text("#{Devise.password_length.min} caractères minimum.")
  end

  it "never prefills the passwords" do
    expect(page.find_field("Nouveau mot de passe", exact: true).value).to be_blank
    expect(page.find_field("Confirmer le nouveau mot de passe").value).to be_blank
  end

  it "submits with a full-width primary button" do
    expect(page).to have_css("button.btn-na-primary.w-100", text: "Changer mon mot de passe")
  end

  it "has no error markup for a valid resource" do
    expect(page).not_to have_css("[role='alert']")
  end

  context "with validation errors" do
    let(:resource) do
      User.new(reset_password_token: "abc123").tap do |user|
        user.errors.add(:password, "est trop court")
        user.errors.add(:password_confirmation, "ne correspond pas")
      end
    end

    it "shows each error next to its field" do
      expect(page).to have_text("est trop court")
      expect(page).to have_text("ne correspond pas")
    end
  end

  context "with an invalid or expired token" do
    let(:resource) do
      User.new(reset_password_token: "abc123").tap do |user|
        user.errors.add(:reset_password_token, "est invalide")
      end
    end

    it "warns that the link is no longer valid, with a way to ask for a new one" do
      expect(page).to have_css("[role='alert']", text: "invalide")
      expect(page).to have_link("Demander un nouveau lien", href: "/users/password/new")
    end
  end
end
