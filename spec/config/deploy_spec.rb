require "rails_helper"

RSpec.describe "config/deploy.yml" do
  let(:deploy) { YAML.load_file(Rails.root.join("config/deploy.yml")) }
  let(:sender_address) { Devise.mailer_sender[/<(.+)>/, 1] || Devise.mailer_sender }

  describe "SMTP authentication" do
    let(:username) { deploy.dig("env", "clear", "SMTP_USERNAME") }

    it "names a mailbox to sign in with" do
      expect(username).to be_present
    end

    it "does not sign in with the sender address, which is only an alias" do
      expect(username).not_to eq(sender_address)
    end
  end
end
