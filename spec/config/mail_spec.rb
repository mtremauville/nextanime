require "rails_helper"

RSpec.describe "config/mail.yml" do
  let(:environment) { { "SMTP_USERNAME" => "no-reply@tremic.fr", "SMTP_PASSWORD" => "test-password" } }
  let(:settings) do
    stub_const("ENV", ENV.to_h.merge(environment))
    Rails.application.config_for(:mail, env: "production")
  end

  it "sends through the SMTP server of Hostinger" do
    expect(settings).to include(address: "smtp.hostinger.com", port: 587, domain: "tremic.fr")
  end

  it "encrypts the connection with STARTTLS and authenticates" do
    expect(settings).to include(enable_starttls_auto: true, authentication: "plain")
  end

  it "does not wait forever for the server" do
    expect(settings.values_at(:open_timeout, :read_timeout)).to all(be_between(1, 10))
  end

  it "logs in with the mailbox given by the environment" do
    expect(settings[:user_name]).to eq("no-reply@tremic.fr")
  end

  it "takes the password from the environment" do
    expect(settings[:password]).to eq("test-password")
  end

  it "carries no password of its own" do
    stub_const("ENV", ENV.to_h.except("SMTP_PASSWORD"))

    expect(Rails.application.config_for(:mail, env: "production")[:password]).to be_blank
  end
end
