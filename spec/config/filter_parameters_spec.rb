require "rails_helper"

RSpec.describe "Filtered parameters" do
  let(:filter) { ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters) }

  def filtered(params)
    filter.filter(params)
  end

  it "hides the password and its confirmation" do
    result = filtered("user" => { "password" => "secret123", "password_confirmation" => "secret123" })

    expect(result["user"].values).to all(eq("[FILTERED]"))
  end

  it "hides the current password asked when the account is changed" do
    expect(filtered("user" => { "current_password" => "secret123" })["user"]["current_password"]).to eq("[FILTERED]")
  end

  it "hides the tokens used to reset a password or confirm an account" do
    result = filtered("reset_password_token" => "abc", "confirmation_token" => "def")

    expect(result.values).to all(eq("[FILTERED]"))
  end

  it "hides the email address, which is personal data" do
    expect(filtered("user" => { "email" => "a@b.fr" })["user"]["email"]).to eq("[FILTERED]")
  end

  it "keeps the harmless parameters readable" do
    expect(filtered("page" => "2", "genre" => "Action")).to eq("page" => "2", "genre" => "Action")
  end
end
