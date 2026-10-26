require "rails_helper"

RSpec.describe Organisms::SignUpFormComponent, type: :component do
  let(:resource) do
    User.new(
      email: "mika@example.com",
      password: "secret-value-123",
      password_confirmation: "secret-value-123",
      privacy_policy: "1"
    )
  end

  before { render_inline(described_class.new(resource: resource)) }

  it "posts to the registration route" do
    expect(page).to have_css("form[action='/users'][method='post']")
  end

  it "prefills the e-mail address" do
    expect(page).to have_field("Adresse e-mail", type: "email", with: "mika@example.com")
  end

  it "never prefills the passwords" do
    expect(page).to have_field("Mot de passe", type: "password", exact: true)
    expect(page).to have_field("Confirmer le mot de passe", type: "password")
    expect(page).to have_no_css("input[type='password'][value]")
  end

  it "submits the fields under the user scope" do
    expect(page).to have_css("input[name='user[email]']")
    expect(page).to have_css("input[name='user[password]']")
    expect(page).to have_css("input[name='user[password_confirmation]']")
    expect(page).to have_css("input[type='checkbox'][name='user[privacy_policy]']")
  end

  it "helps the browser suggest a new password" do
    expect(page).to have_css("input[name='user[email]'][autocomplete='email']")
    expect(page).to have_css("input[name='user[password]'][autocomplete='new-password']")
    expect(page).to have_css("input[name='user[password_confirmation]'][autocomplete='new-password']")
  end

  it "reminds the minimum password length and links it to the field" do
    expect(page).to have_css("#field_user_password_hint", text: "12 caractères minimum.")
    expect(page).to have_css("input[name='user[password]'][aria-describedby='field_user_password_hint']")
  end

  it "keeps the privacy policy checked once accepted" do
    expect(page).to have_checked_field("J'accepte la politique de confidentialité")
  end

  it "submits with a full-width primary button" do
    expect(page).to have_css("button.btn-na-primary.w-100[type='submit']", text: "Créer mon compte")
  end

  it "has no error markup for a valid resource" do
    expect(page).to have_no_css("[role='alert']")
  end

  context "when the privacy policy is not accepted" do
    let(:resource) { User.new(privacy_policy: "0") }

    it "leaves the box unchecked" do
      expect(page).to have_unchecked_field("J'accepte la politique de confidentialité")
    end
  end

  context "with validation errors" do
    let(:resource) do
      User.new(email: "mika@example.com").tap do |user|
        user.errors.add(:email, "est déjà utilisé(e)")
        user.errors.add(:password, "est trop court")
        user.errors.add(:password_confirmation, "ne concorde pas")
        user.errors.add(:privacy_policy, "doit être accepté(e)")
      end
    end

    it "shows each error next to its field" do
      expect(page).to have_css("#field_user_email_error[role='alert']", text: "est déjà utilisé(e)")
      expect(page).to have_css("#field_user_password_error[role='alert']", text: "est trop court")
      expect(page).to have_css("#field_user_password_confirmation_error[role='alert']", text: "ne concorde pas")
      expect(page).to have_css("#field_user_privacy_policy_error[role='alert']", text: "doit être accepté(e)")
    end
  end
end
