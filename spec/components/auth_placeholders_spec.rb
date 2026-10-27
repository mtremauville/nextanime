require "rails_helper"

RSpec.describe "Authentication placeholders", type: :component do
  it "suggests the format of an e-mail address on the sign in form" do
    render_inline(Organisms::SignInFormComponent.new(resource: User.new))

    expect(page).to have_field("Adresse e-mail", placeholder: "toi@exemple.fr")
  end

  it "suggests the format of an e-mail address on the sign up form" do
    render_inline(Organisms::SignUpFormComponent.new(resource: User.new))

    expect(page).to have_field("Adresse e-mail", placeholder: "toi@exemple.fr")
  end
end
