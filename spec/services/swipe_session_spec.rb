require "rails_helper"

RSpec.describe SwipeSession do
  def card
    create(:anime, cover_image_url: "https://img.test/cover.jpg")
  end

  def session_for(store, swiped: [], **options)
    described_class.new(store, swiped_anime_ids: swiped, **options)
  end

  context "without a session in progress" do
    it "draws the cards of a new session" do
      cards = Array.new(3) { card }

      expect(session_for({}).animes).to match_array(cards)
    end

    it "draws at most the requested number of cards" do
      Array.new(3) { card }
      session = session_for({}, size: 2)

      expect(session.animes.size).to eq(2)
      expect(session.total).to eq(2)
    end

    it "remembers the drawn cards" do
      Array.new(3) { card }
      store = {}

      drawn = session_for(store).animes

      expect(store[:swipe_deck_ids]).to eq(drawn.map(&:id))
    end

    it "leaves the swiped anime out of the new session" do
      seen = card
      other = card

      expect(session_for({}, swiped: [ seen.id ]).animes).to eq([ other ])
    end

    it "starts with nothing completed" do
      Array.new(3) { card }
      session = session_for({})

      expect(session.total).to eq(3)
      expect(session.completed).to eq(0)
    end

    it "draws nothing from an empty catalog" do
      session = session_for({})

      expect(session.animes).to eq([])
      expect(session.total).to eq(0)
      expect(session.completed).to eq(0)
    end
  end

  context "with a session in progress" do
    let!(:first_card) { card }
    let!(:second_card) { card }
    let!(:third_card) { card }
    let(:store) { { swipe_deck_ids: [ third_card.id, first_card.id, second_card.id ] } }

    it "resumes the remembered cards in the same order" do
      expect(session_for(store).animes).to eq([ third_card, first_card, second_card ])
    end

    it "leaves the cards already swiped out" do
      session = session_for(store, swiped: [ third_card.id ])

      expect(session.animes).to eq([ first_card, second_card ])
    end

    it "counts the cards already swiped as completed" do
      session = session_for(store, swiped: [ third_card.id ])

      expect(session.total).to eq(3)
      expect(session.completed).to eq(1)
    end

    it "keeps the remembered cards while the session is not over" do
      session_for(store, swiped: [ third_card.id ]).animes

      expect(store[:swipe_deck_ids]).to eq([ third_card.id, first_card.id, second_card.id ])
    end

    it "draws a new session once every card has been swiped" do
      swiped = [ first_card.id, second_card.id, third_card.id ]
      fresh = card

      session = session_for(store, swiped: swiped)

      expect(session.animes).to eq([ fresh ])
      expect(store[:swipe_deck_ids]).to eq([ fresh.id ])
      expect(session.completed).to eq(0)
    end

    it "draws a new session when a remembered card no longer exists" do
      store[:swipe_deck_ids] = [ first_card.id, 0 ]

      session = session_for(store)

      expect(session.animes).to match_array([ first_card, second_card, third_card ])
      expect(session.total).to eq(3)
    end
  end
end
