require "rails_helper"

RSpec.describe LandingPostersQuery do
  it "gives the cover of each anime of the landing page, by name" do
    create(:anime, anilist_id: 1535, cover_image_url: "https://img.test/death-note.jpg")
    create(:anime, anilist_id: 437, cover_image_url: "https://img.test/perfect-blue.jpg")

    expect(described_class.new.call).to eq(
      death_note: "https://img.test/death-note.jpg",
      perfect_blue: "https://img.test/perfect-blue.jpg"
    )
  end

  it "leaves out an anime that is not in the database" do
    expect(described_class.new.call).to eq({})
  end

  it "leaves out an anime that has no cover" do
    create(:anime, anilist_id: 1535, cover_image_url: nil)

    expect(described_class.new.call).to eq({})
  end

  it "ignores the other anime" do
    create(:anime, anilist_id: 999_999, cover_image_url: "https://img.test/other.jpg")

    expect(described_class.new.call).to eq({})
  end
end
