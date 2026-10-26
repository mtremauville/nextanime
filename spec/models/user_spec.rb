require "rails_helper"

RSpec.describe User, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  include ActiveSupport::Testing::TimeHelpers

  subject(:user) { build(:user) }

  it "has a valid factory" do
    expect(user).to be_valid
  end

  describe "columns" do
    it { is_expected.to have_db_column(:email).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:country).of_type(:string).with_options(default: "FR") }
    it { is_expected.to have_db_index(:email).unique(true) }
    it { is_expected.to have_db_index(:reset_password_token).unique(true) }
    it { is_expected.to have_db_index(:unlock_token).unique(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(12) }
  end

  describe "password storage" do
    it "never stores the password in clear" do
      user = create(:user, password: "correct horse battery staple")

      expect(user.encrypted_password).not_to include("correct horse")
    end
  end

  describe "account locking" do
    it "locks the account after 5 failed attempts" do
      user = create(:user)

      4.times { user.valid_for_authentication? { false } }
      expect(user).not_to be_access_locked

      user.valid_for_authentication? { false }
      expect(user).to be_access_locked
    end

    it "unlocks the account after one hour" do
      user = create(:user)
      user.lock_access!(send_instructions: false)

      expect(user.locked_at).to be_present
      travel_to(61.minutes.from_now) { expect(user).not_to be_access_locked }
    end
  end
end
