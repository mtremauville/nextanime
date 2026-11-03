require "rails_helper"

RSpec.describe "Rate limiting", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    original_store = Rack::Attack.cache.store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    freeze_time { example.run }
    Rack::Attack.cache.store = original_store
  end

  describe "sign in" do
    def sign_in_attempt(ip: "10.0.0.1")
      post user_session_path,
           params: { user: { email: "mika@example.com", password: "wrong" } },
           headers: { "REMOTE_ADDR" => ip }
    end

    it "lets 10 attempts per minute through" do
      10.times { sign_in_attempt }

      expect(response).not_to have_http_status(:too_many_requests)
    end

    it "blocks the 11th attempt of the same address" do
      11.times { sign_in_attempt }

      expect(response).to have_http_status(:too_many_requests)
    end

    it "tells why and for how long" do
      11.times { sign_in_attempt }

      expect(response.headers["Retry-After"].to_i).to be_between(1, 60)
      expect(response.body).to include("Trop de tentatives")
    end

    it "does not block another address" do
      11.times { sign_in_attempt }
      sign_in_attempt(ip: "10.0.0.2")

      expect(response).not_to have_http_status(:too_many_requests)
    end

    it "lets attempts through again after a minute" do
      11.times { sign_in_attempt }
      travel 61.seconds
      sign_in_attempt

      expect(response).not_to have_http_status(:too_many_requests)
    end
  end

  describe "sign up" do
    it "blocks the 11th sign up of the same address within an hour" do
      11.times do
        post user_registration_path, params: { user: { email: "bad" } }, headers: { "REMOTE_ADDR" => "10.0.0.1" }
      end

      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "password reset" do
    def reset_request(email: "mika@example.com", ip: "10.0.0.1")
      post user_password_path, params: { user: { email: email } }, headers: { "REMOTE_ADDR" => ip }
    end

    it "blocks the 6th request of the same address within 15 minutes" do
      6.times { |index| reset_request(email: "user#{index}@example.com") }

      expect(response).to have_http_status(:too_many_requests)
    end

    it "blocks the 4th request for the same e-mail address, whatever the address" do
      4.times { |index| reset_request(ip: "10.0.0.#{index + 1}") }

      expect(response).to have_http_status(:too_many_requests)
    end

    it "counts an e-mail address without caring for the case" do
      3.times { |index| reset_request(ip: "10.0.0.#{index + 1}") }
      reset_request(email: "MIKA@Example.com", ip: "10.0.0.9")

      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "swipes" do
    it "blocks the 101st swipe of the same address within a minute" do
      101.times { post swipes_path, params: { anime_id: 0, liked: true }, headers: { "REMOTE_ADDR" => "10.0.0.1" } }

      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
