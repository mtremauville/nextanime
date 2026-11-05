require "rails_helper"

RSpec.describe Organisms::BottomSheetComponent, type: :component do
  def render_sheet(with_trigger: true)
    sheet = described_class.new(id: "filters-sheet", title: "Filtres", close_label: "Fermer les filtres")

    render_inline(sheet) do |component|
      component.with_trigger { "<button type='button'>Ouvrir</button>".html_safe } if with_trigger
      "Le contenu"
    end
  end

  it "is driven by the sheet controller" do
    render_sheet

    expect(page).to have_css(".na-sheet[data-controller='sheet']")
  end

  it "is a native dialog named by its title" do
    render_sheet

    expect(page).to have_css("dialog#filters-sheet[aria-labelledby='filters-sheet-title']", visible: :all)
    expect(page).to have_css("h2#filters-sheet-title", text: "Filtres", visible: :all)
  end

  it "closes on a click on the backdrop" do
    render_sheet

    expect(page).to have_css("dialog[data-sheet-target='dialog'][data-action='click->sheet#backdrop']", visible: :all)
  end

  it "has a close button named for screen readers, whose cross is hidden from them" do
    render_sheet

    expect(page).to have_css("button.na-sheet__close[aria-label='Fermer les filtres'][data-action='sheet#close']", visible: :all)
    expect(page).to have_css("button.na-sheet__close span[aria-hidden='true']", text: "×", visible: :all)
  end

  it "holds the content in the sheet" do
    render_sheet

    expect(page).to have_css("dialog .na-sheet__content", text: "Le contenu", visible: :all)
  end

  it "puts the trigger outside the dialog, and opens the sheet when it is clicked" do
    render_sheet

    expect(page).to have_css(".na-sheet__trigger[data-action='click->sheet#open'] button", text: "Ouvrir")
    expect(page).to have_no_css("dialog button", text: "Ouvrir", visible: :all)
  end

  it "draws no trigger when none is given" do
    render_sheet(with_trigger: false)

    expect(page).to have_no_css(".na-sheet__trigger")
  end
end
