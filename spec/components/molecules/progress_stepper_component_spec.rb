require "rails_helper"

RSpec.describe Molecules::ProgressStepperComponent, type: :component do
  def render_stepper(progress: 3, episodes: 12, status: nil)
    entry = create(:watchlist_entry, :watching, progress: progress, anime: create(:anime, episodes: episodes))
    render_inline(described_class.new(entry: entry, status: status))
    entry
  end

  it "moves the progress forward with a patch request" do
    entry = render_stepper

    expect(page).to have_css("form.na-stepper__form--advance[action='/watchlist/#{entry.id}'] input[name=_method][value=patch]", visible: :all)
    expect(page).to have_css("form.na-stepper__form--advance input[name=move][value=advance]", visible: :all)
  end

  it "moves the progress back with a patch request" do
    entry = render_stepper

    expect(page).to have_css("form.na-stepper__form--rewind[action='/watchlist/#{entry.id}'] input[name=_method][value=patch]", visible: :all)
    expect(page).to have_css("form.na-stepper__form--rewind input[name=move][value=rewind]", visible: :all)
  end

  it "names each button after the anime" do
    entry = render_stepper
    title = entry.anime.display_title

    expect(page).to have_css("button[aria-label='Un épisode de plus pour #{title}']")
    expect(page).to have_css("button[aria-label='Un épisode de moins pour #{title}']")
  end

  it "keeps the status filter in the address of both buttons" do
    render_stepper(status: "watching")

    expect(page).to have_css("form[action$='?status=watching']", count: 2)
  end

  it "has no filter in the address without a status" do
    render_stepper

    expect(page).to have_no_css("form[action*='?']")
  end

  it "disables the minus button before the first episode" do
    render_stepper(progress: 0)

    expect(page).to have_css("form.na-stepper__form--rewind button[disabled]")
    expect(page).to have_no_css("form.na-stepper__form--advance button[disabled]")
  end

  it "disables the plus button after the last episode" do
    render_stepper(progress: 12)

    expect(page).to have_css("form.na-stepper__form--advance button[disabled]")
    expect(page).to have_no_css("form.na-stepper__form--rewind button[disabled]")
  end

  it "disables nothing in the middle of the anime" do
    render_stepper

    expect(page).to have_no_css("button[disabled]")
  end

  it "never disables the plus button while the episode count is unknown" do
    render_stepper(progress: 5, episodes: nil)

    expect(page).to have_no_css("button[disabled]")
  end
end
