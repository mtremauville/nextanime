require "rails_helper"

RSpec.describe Molecules::CheckboxFieldComponent, type: :component do
  subject(:render_component) { render_inline(described_class.new(**options)) }

  let(:options) { { name: "user[remember_me]", label: "Se souvenir de moi" } }

  it "renders a checkbox linked to its label" do
    render_component

    expect(page).to have_unchecked_field("Se souvenir de moi")
    expect(page).to have_css("label[for='field_user_remember_me']", text: "Se souvenir de moi")
  end

  it "sends 1 when checked and 0 when unchecked" do
    render_component

    expect(page).to have_css("input[type='checkbox'][name='user[remember_me]'][value='1']")
    expect(page).to have_css("input[type='hidden'][name='user[remember_me]'][value='0']", visible: :all)
  end

  context "when checked" do
    let(:options) { { name: "user[remember_me]", label: "Se souvenir de moi", checked: true } }

    it "renders the checkbox as checked" do
      render_component

      expect(page).to have_checked_field("Se souvenir de moi")
    end
  end

  it "has no error markup when valid" do
    render_component

    expect(page).to have_no_css("[role='alert']")
    expect(page).to have_no_css("input[aria-invalid]")
  end

  context "with an error" do
    let(:options) { { name: "user[terms]", label: "J'accepte", error: "doit être accepté(e)" } }

    it "flags the checkbox and shows the message" do
      render_component

      expect(page).to have_css("input[type='checkbox'].is-invalid[aria-invalid='true'][aria-describedby='field_user_terms_error']")
      expect(page).to have_css("#field_user_terms_error[role='alert']", text: "doit être accepté(e)")
    end
  end

  context "with extra attributes" do
    let(:options) { { name: "user[remember_me]", label: "Se souvenir de moi", data: { testid: "remember" } } }

    it "passes them to the checkbox" do
      render_component

      expect(page).to have_css("input[type='checkbox'][data-testid='remember']")
    end
  end
end
