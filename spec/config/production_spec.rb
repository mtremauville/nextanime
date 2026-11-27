require "rails_helper"

RSpec.describe "config/environments/production.rb" do
  let(:source) { Rails.root.join("config/environments/production.rb").read }

  it "leaves the password reset on, as the other environments do" do
    expect(source).not_to match(/password_reset_enabled\s*=\s*false/)
  end
end
