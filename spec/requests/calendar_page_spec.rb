require "rails_helper"

RSpec.describe "The calendar page", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:friday_noon) { Time.zone.local(2026, 10, 23, 12, 0) }
  let(:html) { Capybara.string(response.body) }

  def show_calendar(at: friday_noon)
    travel_to(at) { get calendar_path }
  end

  def anime_airing(title, day, hour, minute, episode)
    create(:anime, title_romaji: title, title_english: nil, next_episode: episode,
                   next_airing_at: Time.zone.local(2026, 10, day, hour, minute))
  end

  it "is open to visitors" do
    show_calendar

    expect(response).to have_http_status(:ok)
  end

  it "is open to members" do
    sign_in create(:user)

    show_calendar

    expect(response).to have_http_status(:ok)
  end

  it "names the season and the seven days it looks at" do
    show_calendar

    expect(html).to have_css("h1", text: "Automne 2026")
    expect(html).to have_text("Du 23 au 29 octobre")
  end

  it "names both months when the seven days run over two of them" do
    show_calendar(at: Time.zone.local(2026, 10, 28, 12, 0))

    expect(html).to have_text("Du 28 octobre au 3 novembre")
  end

  it "gives each of the seven days a section, today first" do
    anime_airing("Glitch Samurai", 25, 20, 0, 4)

    show_calendar

    expect(html).to have_css("section[aria-label]", count: 7)
    expect(html.all("section[aria-label]").first(2).map { |section| section["aria-label"] })
      .to eq([ "Aujourd'hui · vendredi 23", "Samedi 24" ])
  end

  it "lists an anime under the day and the time it airs, with its episode" do
    anime = anime_airing("Glitch Samurai", 23, 20, 0, 4)

    show_calendar

    friday = html.find("section[aria-label='Aujourd\\'hui · vendredi 23']")
    expect(friday).to have_link("Glitch Samurai", href: anime_path(anime))
    expect(friday).to have_text("Épisode 4")
    expect(friday).to have_text("20:00")
  end

  it "says when nothing airs on a day" do
    anime_airing("Glitch Samurai", 23, 20, 0, 4)

    show_calendar

    expect(html.find("section[aria-label='Samedi 24']")).to have_text("Aucune sortie ce jour-là")
  end

  it "says when nothing airs in the seven days" do
    show_calendar

    expect(html).to have_text("Aucune sortie annoncée pour les 7 prochains jours")
    expect(html).to have_no_css("section[aria-label]")
  end
end
