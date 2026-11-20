require "rails_helper"

RSpec.describe Atoms::HiddenFieldsComponent, type: :component do
  def render_fields(fields)
    render_inline(described_class.new(fields: fields))
  end

  def hidden(name)
    page.all("input[type='hidden'][name='#{name}']", visible: :all).map { |input| input[:value] }
  end

  it "turns a value into a hidden field" do
    render_fields(season: "fall")

    expect(hidden("season")).to eq(%w[fall])
  end

  it "turns a list into one hidden field for each value, named as a list" do
    render_fields(formats: %w[tv movie])

    expect(hidden("formats[]")).to eq(%w[tv movie])
  end

  it "sends numbers as texts" do
    render_fields(year_from: 1990, genre_ids: [ 3, 5 ])

    expect(hidden("year_from")).to eq(%w[1990])
    expect(hidden("genre_ids[]")).to eq(%w[3 5])
  end

  it "keeps a zero" do
    render_fields(year_from: 0)

    expect(hidden("year_from")).to eq(%w[0])
  end

  it "leaves out what is empty" do
    render_fields(q: "", sort: nil, formats: [], season: "fall")

    expect(page).to have_css("input[type='hidden']", count: 1, visible: :all)
    expect(hidden("season")).to eq(%w[fall])
  end

  it "gives the fields no id, so that the same name can come back in the page" do
    render_fields(q: "monster")

    expect(page).to have_css("input[type='hidden'][name='q']:not([id])", visible: :all)
  end

  it "renders nothing without fields" do
    render_fields({})

    expect(page).to have_no_css("input", visible: :all)
  end
end
