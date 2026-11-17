require "rails_helper"

# Audits the pages of the app against WCAG 2.1 level AA, on a phone and on a wide screen,
# in the dark and in the light theme.
RSpec.describe "Accessibility of the pages", type: :system, js: true do
  include Warden::Test::Helpers

  let(:wcag_aa) { %i[wcag2a wcag2aa wcag21a wcag21aa] }
  let(:genre) { create(:genre, name: "Thriller") }
  let!(:anime) do
    create(:anime, title_romaji: "Close Series", title_english: nil, genres: [ genre ], format: :tv,
                   description: "A dark story.", episodes: 12, cover_image_url: "https://img.test/cover.jpg")
  end
  let(:user) { create(:user) }

  public_pages = {
    "the swipe page" => "/",
    "the catalogue" => "/catalogue",
    "the sign in page" => "/users/sign_in",
    "the sign up page" => "/users/sign_up",
    "the forgotten password page" => "/users/password/new",
    "the styleguide" => "/styleguide"
  }

  member_pages = {
    "the profile" => "/profil",
    "the recommendations" => "/recos",
    "the watchlist" => "/watchlist",
    "the calendar" => "/calendrier"
  }

  before do
    3.times do |index|
      create(:anime, title_romaji: "Anime #{index}", title_english: nil, genres: [ genre ], popularity: 100 - index,
                     cover_image_url: "https://img.test/cover.jpg")
    end
    Warden.test_mode!
  end

  after { Warden.test_reset! }

  def sign_in_with_a_taste_profile
    user.create_taste_profile!.record_swipe(anime, liked: true)
    login_as(user, scope: :user)
  end

  def expect_no_violation_on(path, theme:)
    visit path
    expect(page).to have_css("main#main")
    page.execute_script("document.documentElement.dataset.bsTheme = '#{theme}'")
    wait_for_the_transitions
    expect(page).to be_axe_clean.according_to(*wcag_aa)
  end

  # Changing the theme runs CSS transitions: the audit has to read the final colors, not the ones in between.
  def wait_for_the_transitions
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 until page.evaluate_script(<<~JS)
        document.getAnimations().every((animation) => animation.effect.getTiming().iterations === Infinity)
      JS
    end
  end

  { "a phone" => [ 393, 852 ], "a wide screen" => [ 1400, 900 ] }.each do |screen, size|
    %w[dark light].each do |theme|
      context "on #{screen}, in the #{theme} theme" do
        before { page.current_window.resize_to(*size) }

        public_pages.each do |name, path|
          it "has no WCAG AA violation on #{name}" do
            expect_no_violation_on(path, theme: theme)
          end
        end

        it "has no WCAG AA violation on the page of an anime" do
          expect_no_violation_on(anime_path(anime), theme: theme)
        end

        context "when signed in" do
          before { sign_in_with_a_taste_profile }

          member_pages.each do |name, path|
            it "has no WCAG AA violation on #{name}" do
              expect_no_violation_on(path, theme: theme)
            end
          end
        end
      end
    end
  end

  describe "reflow on a phone" do
    before { page.current_window.resize_to(393, 852) }

    def horizontal_overflow
      page.evaluate_script("document.documentElement.scrollWidth - document.documentElement.clientWidth")
    end

    public_pages.each do |name, path|
      it "does not scroll sideways on #{name}" do
        visit path
        expect(page).to have_css("main#main")
        expect(horizontal_overflow).to be <= 0
      end
    end

    context "when signed in" do
      before { sign_in_with_a_taste_profile }

      member_pages.each do |name, path|
        it "does not scroll sideways on #{name}" do
          visit path
          expect(page).to have_css("main#main")
          expect(horizontal_overflow).to be <= 0
        end
      end
    end
  end
  describe "open states on a phone" do
    before { page.current_window.resize_to(393, 852) }

    def audit_in_theme(theme)
      page.execute_script("document.documentElement.dataset.bsTheme = '#{theme}'")
      wait_for_the_transitions
      expect(page).to be_axe_clean.according_to(*wcag_aa)
    end

    %w[dark light].each do |theme|
      context "in the #{theme} theme" do
        it "has no WCAG AA violation in the burger menu" do
          visit root_path
          click_button "Ouvrir le menu"
          expect(page).to have_css("#mobile-menu", visible: :visible)
          audit_in_theme(theme)
        end

        it "has no WCAG AA violation in the filters sheet" do
          visit catalogue_path
          click_button "Filtres", exact: true
          expect(page).to have_css("dialog#filters-sheet[open]")
          audit_in_theme(theme)
        end

        it "has no WCAG AA violation in the catalogue with an active filter" do
          create(:anime, title_romaji: "Film", title_english: nil, format: :movie, genres: [ genre ])
          visit catalogue_path(formats: %w[movie tv])
          expect(page).to have_css(".na-filter-chip")
          audit_in_theme(theme)
        end

        context "when signed in" do
          before { sign_in_with_a_taste_profile }

          it "has no WCAG AA violation in the confirmation to delete the account" do
            visit "/profil"
            click_button "Supprimer mon compte"
            expect(page).to have_css("#delete-account", visible: :visible)
            audit_in_theme(theme)
          end
        end
      end
    end
  end
  describe "touch targets on a phone" do
    before { page.current_window.resize_to(393, 852) }

    # The controls that a thumb cannot hit with ease: under 44 px wide or high. Left out: a link inside
    # a sentence, a link stretched over its whole card, and a check box whose label is the real target.
    def small_targets
      page.evaluate_script(<<~JS)
        (() => {
          const MIN = 44
          const selector = "a[href], button, input:not([type=hidden]), select, textarea, summary, [role=button]"
          const targetOf = (element) => {
            const isCheck = element.matches("input[type=checkbox], input[type=radio]")
            return (isCheck && element.labels && element.labels[0]) || element
          }
          const describe = (element, rect) => {
            const name = element.tagName.toLowerCase() + (element.id ? "#" + element.id : "") +
              (element.className && typeof element.className === "string" ? "." + element.className.trim().split(/\\s+/).join(".") : "")
            const text = (element.getAttribute("aria-label") || element.textContent || "").trim().replace(/\\s+/g, " ").slice(0, 24)
            return name + " [" + text + "] " + Math.round(rect.width) + "x" + Math.round(rect.height)
          }
          return Array.from(document.querySelectorAll(selector))
            .filter((element) => element.getClientRects().length > 0)
            .filter((element) => getComputedStyle(element).visibility !== "hidden")
            .filter((element) => !element.matches(".stretched-link, .visually-hidden, .visually-hidden-focusable"))
            .filter((element) => getComputedStyle(element).display !== "inline")
            .map((element) => ({ element, rect: targetOf(element).getBoundingClientRect() }))
            .filter(({ rect }) => !(rect.width <= 1 && rect.height <= 1))
            .filter(({ rect }) => Math.round(rect.width) < MIN || Math.round(rect.height) < MIN)
            .map(({ element, rect }) => describe(element, rect))
        })()
      JS
    end

    def expect_no_small_target
      expect(page).to have_css("main#main")
      targets = small_targets
      expect(targets).to be_empty, "Controls under 44 px:\n#{targets.map { |target| "TARGET|#{target}" }.join("\n")}"
    end

    public_pages.each do |name, path|
      it "keeps every control at least 44 px wide and high on #{name}" do
        visit path
        expect_no_small_target
      end
    end

    it "keeps every control at least 44 px wide and high on the page of an anime" do
      visit anime_path(anime)
      expect_no_small_target
    end

    it "keeps every control at least 44 px wide and high in the burger menu" do
      visit root_path
      click_button "Ouvrir le menu"
      expect(page).to have_css("#mobile-menu", visible: :visible)
      expect_no_small_target
    end

    it "keeps every control at least 44 px wide and high in the filters sheet" do
      visit catalogue_path
      click_button "Filtres", exact: true
      expect(page).to have_css("dialog#filters-sheet[open]")
      expect_no_small_target
    end

    context "when signed in and asking to delete the account" do
      before { sign_in_with_a_taste_profile }

      it "keeps every control at least 44 px wide and high in the confirmation" do
        visit "/profil"
        click_button "Supprimer mon compte"
        expect(page).to have_css("#delete-account", visible: :visible)
        expect_no_small_target
      end
    end

    context "when signed in" do
      before { sign_in_with_a_taste_profile }

      member_pages.each do |name, path|
        it "keeps every control at least 44 px wide and high on #{name}" do
          visit path
          expect_no_small_target
        end
      end
    end
  end
  describe "keyboard on a wide screen" do
    before { page.current_window.resize_to(1400, 900) }

    def press(key)
      page.driver.browser.action.send_keys(key).perform
    end

    def focused_control
      page.evaluate_script(<<~JS)
        (() => {
          const element = document.activeElement
          if (!element || element === document.body) return null
          const style = getComputedStyle(element)
          const rect = element.getBoundingClientRect()
          const outline = style.outlineStyle !== "none" && parseFloat(style.outlineWidth) > 0
          const name = element.tagName.toLowerCase() + (element.id ? "#" + element.id : "") +
            (typeof element.className === "string" && element.className ? "." + element.className.trim().split(/\\s+/).join(".") : "")
          const text = (element.getAttribute("aria-label") || element.textContent || "").trim().replace(/\\s+/g, " ").slice(0, 24)
          return {
            position: Array.prototype.indexOf.call(document.getElementsByTagName("*"), element),
            name: name + " [" + text + "]",
            indicated: outline || style.boxShadow !== "none",
            hidden: rect.width <= 1 && rect.height <= 1
          }
        })()
      JS
    end

    # The controls reached with the Tab key that show nothing around them when they have the focus.
    def tab_stops_without_focus_indicator
      seen = []
      missing = []
      80.times do
        press(:tab)
        stop = focused_control
        break if stop.nil? || seen.include?(stop["position"])

        seen << stop["position"]
        missing << stop["name"] unless stop["indicated"] || stop["hidden"]
      end
      missing
    end

    def expect_a_visible_focus_everywhere
      expect(page).to have_css("main#main")
      missing = tab_stops_without_focus_indicator
      expect(missing).to be_empty, "Controls with no visible focus:\n#{missing.map { |name| "NOFOCUS|#{name}" }.join("\n")}"
    end

    it "offers the skip link first, and leads to the main content" do
      visit catalogue_path
      expect(page).to have_css("main#main")

      press(:tab)
      expect(page.evaluate_script("document.activeElement.textContent.trim()")).to eq("Aller au contenu")

      press(:enter)
      focused = -> { "The focus is on: #{page.evaluate_script('document.activeElement.outerHTML.slice(0, 160)')}" }
      expect(page).to have_css("main#main:focus"), focused
    end

    public_pages.each do |name, path|
      it "shows where the focus is on every control of #{name}" do
        visit path
        expect_a_visible_focus_everywhere
      end
    end

    it "shows where the focus is on every control of the page of an anime" do
      visit anime_path(anime)
      expect_a_visible_focus_everywhere
    end

    context "when signed in" do
      before { sign_in_with_a_taste_profile }

      member_pages.each do |name, path|
        it "shows where the focus is on every control of #{name}" do
          visit path
          expect_a_visible_focus_everywhere
        end
      end
    end
  end
end
