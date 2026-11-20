require "rails_helper"

RSpec.describe "Reset password e-mail", type: :mailer do
  let(:user) { create(:user, email: "ayako@example.com") }
  let(:mail) { Devise::Mailer.reset_password_instructions(user, "abc123") }
  let(:html) { Capybara.string(mail.html_part.decoded) }
  let(:text) { mail.text_part.decoded }
  let(:reset_url) { "http://example.com/users/password/edit?reset_password_token=abc123" }

  it "has a subject that says what it is for" do
    expect(mail.subject).to eq("Réinitialise ton mot de passe NextAnime")
  end

  it "comes with an HTML and a plain text version" do
    expect(mail).to be_multipart
    expect(mail.html_part).to be_present
    expect(mail.text_part).to be_present
  end

  describe "HTML version" do
    it "declares its language and its title" do
      expect(html).to have_css("html[lang='fr']")
      expect(html).to have_css("title", text: "Réinitialise ton mot de passe", visible: :all)
    end

    it "shows the brand as text, not as an image" do
      expect(html).to have_css("[data-role='brand']", text: "NextAnime")
      expect(mail.html_part.decoded).not_to match(/<img/)
    end

    it "hides a preview text for the inbox" do
      expect(html).to have_css(
        "[data-role='preheader']",
        text: "Choisis un nouveau mot de passe en un clic",
        visible: :all
      )
    end

    it "has a single main heading" do
      expect(html).to have_css("h1", count: 1, text: "Réinitialise ton mot de passe")
    end

    it "speaks to the user informally" do
      expect(html).to have_text("Tu as demandé")
    end

    it "offers a button carrying the token" do
      expect(html).to have_css(
        "a[data-role='cta'][href='#{reset_url}']",
        text: "Choisir un nouveau mot de passe"
      )
    end

    it "gives the raw link as a fallback" do
      expect(html).to have_text("Copie ce lien")
      expect(html).to have_css("a[data-role='fallback-link'][href='#{reset_url}']", text: reset_url)
    end

    it "tells how long the link stays valid" do
      expect(html).to have_text("environ 2 heures")
    end

    it "reassures someone who did not ask for it" do
      expect(html).to have_text("ignore simplement cet e-mail")
    end

    it "says in the footer who the e-mail was sent to" do
      expect(html).to have_css("[data-role='footer']", text: "ayako@example.com")
    end

    it "uses layout tables that assistive technologies skip" do
      expect(html).to have_css("table[role='presentation']", minimum: 1)
    end
  end

  describe "plain text version" do
    it "contains the link" do
      expect(text).to include(reset_url)
    end

    it "speaks informally and reassures" do
      expect(text).to include("Tu as demandé")
      expect(text).to include("ignore simplement cet e-mail")
    end

    it "contains no HTML" do
      expect(text).not_to match(/<[a-z\/]/i)
    end
  end
end
