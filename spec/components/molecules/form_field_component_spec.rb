require "rails_helper"

RSpec.describe Molecules::FormFieldComponent, type: :component do
  it "renders an input linked to its label" do
    render_inline(described_class.new(name: "email", label: "Adresse e-mail", type: "email"))

    expect(page).to have_field("Adresse e-mail", type: "email")
  end

  it "builds a valid id from a nested field name" do
    render_inline(described_class.new(name: "user[email]", label: "Adresse e-mail"))

    expect(page).to have_css("input#field_user_email[name='user[email]']")
  end

  it "prefills the value" do
    render_inline(described_class.new(name: "email", label: "Adresse e-mail", value: "mickael@exemple.fr"))

    expect(page).to have_field("Adresse e-mail", with: "mickael@exemple.fr")
  end

  it "never echoes the value of a password field" do
    render_inline(described_class.new(name: "password", label: "Mot de passe", type: "password", value: "secret"))

    expect(page).to have_no_css("input[value]")
  end

  it "has no error markup when the field is valid" do
    render_inline(described_class.new(name: "email", label: "Adresse e-mail"))

    expect(page).to have_no_css(".is-invalid")
    expect(page).to have_no_css("[aria-invalid]")
    expect(page).to have_no_css("[role='alert']")
  end

  it "flags the input and shows the error message" do
    render_inline(described_class.new(name: "email", label: "Adresse e-mail", error: "est invalide"))

    expect(page).to have_css("input.is-invalid[aria-invalid='true'][aria-describedby='field_email_error']")
    expect(page).to have_css("#field_email_error[role='alert']", text: "est invalide")
  end

  it "shows the hint and links it to the input" do
    render_inline(described_class.new(name: "password", label: "Mot de passe", hint: "12 caractères minimum"))

    expect(page).to have_css("#field_password_hint", text: "12 caractères minimum")
    expect(page).to have_css("input[aria-describedby='field_password_hint']")
  end

  it "links both the hint and the error to the input" do
    render_inline(described_class.new(name: "password", label: "Mot de passe", hint: "12 caractères minimum", error: "est trop court"))

    expect(page).to have_css("input[aria-describedby='field_password_hint field_password_error']")
  end

  it "passes extra attributes to the input" do
    render_inline(described_class.new(name: "email", label: "Adresse e-mail", autocomplete: "email", required: true))

    expect(page).to have_css("input[autocomplete='email'][required]")
  end
end
