require "rails_helper"

RSpec.describe "Taste session of the swipe deck", type: :request do
  it "gives a new visitor the taste session cookie as soon as the deck is shown" do
    get root_path

    expect(cookies[:taste_session]).to be_present
  end

  it "does not create a taste profile just by showing the deck" do
    expect { get root_path }.not_to change(TasteProfile, :count)
  end

  it "keeps the cookie of a visitor who comes back" do
    get root_path
    first_cookie = cookies[:taste_session]
    get root_path

    expect(first_cookie).to be_present
    expect(cookies[:taste_session]).to eq(first_cookie)
  end
end
