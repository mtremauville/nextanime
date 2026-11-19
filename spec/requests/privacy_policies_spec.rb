require "rails_helper"

RSpec.describe "Privacy policy", type: :request do
  describe "GET /confidentialite" do
    it "is public" do
      get privacy_policy_path

      expect(response).to have_http_status(:ok)
    end

    it "has a single main heading" do
      get privacy_policy_path

      assert_select "main h1", text: "Politique de confidentialité", count: 1
    end

    it "describes what is collected, the cookies and the rights of the user" do
      get privacy_policy_path

      [ "Données collectées", "Cookies", "Tes droits" ].each do |title|
        assert_select "main h2", text: title
      end
    end

    it "links to the data export and to the profile, where the account can be deleted" do
      get privacy_policy_path

      assert_select "main a[href=?]", data_export_path
      assert_select "main a[href=?]", profile_path
    end
  end
end
