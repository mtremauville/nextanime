require "rails_helper"

RSpec.describe "Locale" do
  it "defaults to French" do
    expect(I18n.default_locale).to eq(:fr)
  end

  it "translates the validation messages" do
    user = User.new
    user.validate

    expect(user.errors[:email]).to include("Saisis ton adresse e-mail.")
  end

  it "translates the Devise messages" do
    expect { I18n.t("devise.failure.unauthenticated", raise: true) }.not_to raise_error
    expect(I18n.t("devise.failure.unauthenticated")).to start_with("Vous")
  end
end
