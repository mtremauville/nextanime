require "rails_helper"

RSpec.describe Organisms::AccountFormComponent, type: :component do
  let(:resource) { User.new(email: "mika@example.com") }

  def render_form
    render_inline(described_class.new(resource: resource))
  end

  it "is a region named by its heading" do
    render_form

    expect(page).to have_css("section[aria-labelledby='account-form-title'] h2#account-form-title", text: "Mon compte")
  end

  it "sends the changes to the profile page with a PATCH" do
    render_form

    expect(page).to have_css("form[action='/profil'][method='post']")
    expect(page).to have_css("input[type='hidden'][name='_method'][value='patch']", visible: :all)
  end

  it "prefills the e-mail address" do
    render_form

    expect(page).to have_field("Adresse e-mail", type: "email", with: "mika@example.com")
  end

  it "never prefills the passwords" do
    render_form

    expect(page).to have_field("Nouveau mot de passe", type: "password")
    expect(page).to have_field("Mot de passe actuel", type: "password")
    expect(page).to have_no_css("input[type='password'][value]")
  end

  it "submits the fields under the user scope" do
    render_form

    expect(page).to have_css("input[name='user[email]']")
    expect(page).to have_css("input[name='user[password]']")
    expect(page).to have_css("input[name='user[current_password]']")
  end

  it "helps the browser tell the new password from the current one" do
    render_form

    expect(page).to have_css("input[name='user[email]'][autocomplete='email']")
    expect(page).to have_css("input[name='user[password]'][autocomplete='new-password']")
    expect(page).to have_css("input[name='user[current_password]'][autocomplete='current-password']")
  end

  it "reminds the minimum password length and links it to the field" do
    render_form

    expect(page).to have_css("#field_user_password_hint", text: "12 caractères minimum.")
    expect(page).to have_css("input[name='user[password]'][aria-describedby='field_user_password_hint']")
  end

  it "submits with a clear label" do
    render_form

    expect(page).to have_button("Enregistrer", type: "submit")
  end

  it "has no error markup for a valid resource" do
    render_form

    expect(page).to have_no_css(".invalid-feedback")
    expect(page).to have_no_css("[aria-invalid]")
    expect(page).to have_no_text("empêche")
  end

  context "with validation errors" do
    let(:resource) do
      User.new(email: "bad").tap do |user|
        user.errors.add(:email, "n'est pas valide")
        user.errors.add(:password, "est trop court")
        user.errors.add(:current_password, "est incorrect")
      end
    end

    before { render_form }

    it "shows each error next to its field" do
      expect(page).to have_css("#field_user_email_error", text: "n'est pas valide")
      expect(page).to have_css("#field_user_password_error", text: "est trop court")
      expect(page).to have_css("#field_user_current_password_error", text: "est incorrect")
    end

    it "flags the fields in error and describes them by their error" do
      expect(page).to have_css("input[name='user[email]'][aria-invalid='true'][aria-describedby='field_user_email_error']")
      expect(page).to have_css("input[name='user[password]'][aria-invalid='true'][aria-describedby='field_user_password_hint field_user_password_error']")
      expect(page).to have_css("input[name='user[current_password]'][aria-invalid='true'][aria-describedby='field_user_current_password_error']")
    end
  end

  describe "error summary" do
    def resource_with_errors(*attributes)
      User.new.tap { |user| attributes.each { |attribute| user.errors.add(attribute, "est invalide") } }
    end

    it "announces a single error in the singular" do
      render_inline(described_class.new(resource: resource_with_errors(:email)))

      expect(page).to have_text("1 erreur empêche l'enregistrement.")
    end

    it "announces several errors in the plural" do
      render_inline(described_class.new(resource: resource_with_errors(:email, :password)))

      expect(page).to have_text("2 erreurs empêchent l'enregistrement.")
    end

    it "counts fields, not messages" do
      user = resource_with_errors(:password)
      user.errors.add(:password, "est trop court")
      render_inline(described_class.new(resource: user))

      expect(page).to have_text("1 erreur empêche l'enregistrement.")
    end
  end
end
