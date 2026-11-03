require "rails_helper"

RSpec.describe "Content security policy", type: :request do
  let(:policy) { response.headers["Content-Security-Policy-Report-Only"] }
  let(:nonce) { policy[/'nonce-([^']+)'/, 1] }

  before { get root_path }

  it "is sent with every page" do
    expect(policy).to be_present
  end

  it "only runs the scripts of the app, with a nonce" do
    expect(policy).to match(/script-src 'self' 'nonce-[^']+'/)
  end

  it "allows the Google fonts the layout asks for" do
    expect(policy).to include("style-src 'self' https://fonts.googleapis.com")
    expect(policy).to include("font-src 'self' https://fonts.gstatic.com data:")
  end

  it "forbids plug-ins, framing and a changed base address" do
    expect(policy).to include("object-src 'none'")
    expect(policy).to include("frame-ancestors 'none'")
    expect(policy).to include("base-uri 'self'")
  end

  it "keeps the form submissions on the site" do
    expect(policy).to include("form-action 'self'")
  end

  it "gives the importmap script the nonce of the policy" do
    expect(nonce).to be_present
    expect(Capybara.string(response.body)).to have_css("script[type='importmap'][nonce='#{nonce}']", visible: :all)
  end

  it "keeps the same nonce during the whole session, so that Turbo visits stay valid" do
    first_nonce = nonce
    get root_path

    expect(first_nonce).to be_present
    expect(response.headers["Content-Security-Policy-Report-Only"][/'nonce-([^']+)'/, 1]).to eq(first_nonce)
  end

  it "gives the styles the same nonce, so that the Turbo progress bar is allowed" do
    expect(policy).to match(/style-src 'self' https:\/\/fonts\.googleapis\.com 'nonce-#{Regexp.escape(nonce)}'/)
  end

  it "exposes the nonce to Turbo through the csp-nonce meta tag" do
    expect(Capybara.string(response.body)).to have_css("meta[name='csp-nonce'][content='#{nonce}']", visible: :all)
  end
end
