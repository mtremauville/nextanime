require "rails_helper"

RSpec.describe "Data export routing", type: :routing do
  it "routes GET /profil/export to data_exports#show" do
    expect(get: "/profil/export").to route_to("data_exports#show")
  end

  it "does not let the export be posted, changed or deleted" do
    expect(post: "/profil/export").not_to be_routable
    expect(patch: "/profil/export").not_to be_routable
    expect(delete: "/profil/export").not_to be_routable
  end
end
