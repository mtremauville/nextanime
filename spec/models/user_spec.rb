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

  describe "privacy policy" do
    it "is valid when accepted" do
      expect(build(:user, privacy_policy: "1")).to be_valid
    end

    it "is required, even when the field is missing" do
      user = build(:user, privacy_policy: nil)
      user.validate

      expect(user.errors[:privacy_policy]).to include("doit être accepté(e)")
    end

    it "is refused when the box is unchecked" do
      user = build(:user, privacy_policy: "0")
      user.validate

      expect(user.errors[:privacy_policy]).to include("doit être accepté(e)")
    end

    it "is not asked again when the account is updated" do
      user = User.find(create(:user).id)

      expect(user.update(country: "BE")).to be(true)
    end
  end

  describe "password reset" do
    let(:user) { create(:user, password: "old password is long enough") }
    let(:new_password) { "brand new password is long" }

    def reset_with(token)
      User.reset_password_by_token(
        reset_password_token: token,
        password: new_password,
        password_confirmation: new_password
      )
    end

    it "keeps the reset link valid for two hours" do
      expect(Devise.reset_password_within).to eq(2.hours)
    end

    it "changes the password with a valid token" do
      token = user.send_reset_password_instructions

      reset_with(token)

      expect(user.reload.valid_password?(new_password)).to be(true)
    end

    it "refuses an expired token and keeps the old password" do
      token = user.send_reset_password_instructions

      travel_to(3.hours.from_now) do
        expect(reset_with(token).errors[:reset_password_token]).to be_present
      end

      expect(user.reload.valid_password?(new_password)).to be(false)
    end

    it "refuses an unknown token" do
      expect(reset_with("not-a-token").errors[:reset_password_token]).to be_present
    end

    it "cannot be used twice" do
      token = user.send_reset_password_instructions
      reset_with(token)

      expect(reset_with(token).errors[:reset_password_token]).to be_present
    end
  end
end
