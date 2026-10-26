require "rails_helper"

RSpec.describe Devise::Mailer, type: :mailer do
  describe "#reset_password_instructions" do
    let(:user) { create(:user) }
    let(:mail) { described_class.reset_password_instructions(user, "abc123") }

    it "is sent to the user" do
      expect(mail.to).to eq([ user.email ])
    end

    it "comes from the NextAnime no-reply address" do
      expect(mail.from).to eq([ "no-reply@tremic.fr" ])
      expect(mail[:from].display_names).to eq([ "NextAnime" ])
    end

    it "contains a link to the new password page with the token" do
      expect(mail.body.decoded).to include("/users/password/edit?reset_password_token=abc123")
    end

    it "uses an absolute link" do
      expect(mail.body.decoded).to match(%r{https?://[^/\s"]+/users/password/edit})
    end
  end
end
