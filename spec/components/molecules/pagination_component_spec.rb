require "rails_helper"

RSpec.describe Molecules::PaginationComponent, type: :component do
  let(:url) { ->(number) { "/catalogue?page=#{number}" } }

  def render_pagination(current:, total:)
    render_inline(described_class.new(current: current, total: total, url: url))
  end

  def page_numbers = page.all("a[data-role='page']").map(&:text)

  def gap_count = page.all("[data-role='gap']").size

  it "renders nothing when there is a single page" do
    render_pagination(current: 1, total: 1)

    expect(page).to have_no_css("nav")
  end

  it "is a navigation named Pagination" do
    render_pagination(current: 1, total: 3)

    expect(page).to have_css("nav[aria-label='Pagination']")
  end

  it "lists every page of a short catalogue" do
    render_pagination(current: 1, total: 4)

    expect(page_numbers).to eq(%w[1 2 3 4])
    expect(gap_count).to eq(0)
  end

  it "works with only two pages" do
    render_pagination(current: 2, total: 2)

    expect(page_numbers).to eq(%w[1 2])
  end

  it "shortens a long list after the first pages" do
    render_pagination(current: 1, total: 12)

    expect(page_numbers).to eq(%w[1 2 3 12])
    expect(gap_count).to eq(1)
  end

  it "keeps the neighbours of the current page in the middle" do
    render_pagination(current: 6, total: 12)

    expect(page_numbers).to eq(%w[1 5 6 7 12])
    expect(gap_count).to eq(2)
  end

  it "shortens a long list before the last pages" do
    render_pagination(current: 12, total: 12)

    expect(page_numbers).to eq(%w[1 10 11 12])
    expect(gap_count).to eq(1)
  end

  it "links each page to its url" do
    render_pagination(current: 1, total: 3)

    expect(page).to have_link("2", href: "/catalogue?page=2")
  end

  it "names each page link for a screen reader" do
    render_pagination(current: 1, total: 3)

    expect(page).to have_css("a[data-role='page'][aria-label='Page 2']")
  end

  it "marks the current page" do
    render_pagination(current: 6, total: 12)

    expect(page).to have_css("a[aria-current='page']", text: "6", count: 1)
  end

  it "links to the previous and next pages in the middle" do
    render_pagination(current: 6, total: 12)

    expect(page).to have_css("a[rel='prev'][href='/catalogue?page=5']", text: "← Précédent")
    expect(page).to have_css("a[rel='next'][href='/catalogue?page=7']", text: "Suivant →")
  end

  it "disables the previous link on the first page" do
    render_pagination(current: 1, total: 3)

    expect(page).to have_no_link("← Précédent")
    expect(page).to have_css("span[aria-disabled='true']", text: "← Précédent")
    expect(page).to have_link("Suivant →")
  end

  it "disables the next link on the last page" do
    render_pagination(current: 3, total: 3)

    expect(page).to have_no_link("Suivant →")
    expect(page).to have_css("span[aria-disabled='true']", text: "Suivant →")
    expect(page).to have_link("← Précédent")
  end
end
