require "rails_helper"

RSpec.describe AiringCalendar do
  let(:friday) { Date.new(2026, 10, 23) }
  let(:calendar) { described_class.new(from: friday) }

  def airing_at(day, hour, minute = 0)
    create(:anime, next_episode: 4, next_airing_at: Time.zone.local(day.year, day.month, day.day, hour, minute))
  end

  def airings_of(day) = calendar.days.find { |entry| entry.date == day }.airings

  describe "#days" do
    it "covers the seven days from the given one" do
      expect(calendar.days.map(&:date)).to eq((0..6).map { |offset| friday + offset })
    end

    it "starts today unless told otherwise" do
      expect(described_class.new.days.first.date).to eq(Date.current)
    end

    it "gives every day, even when nothing airs" do
      expect(calendar.days.map(&:airings)).to all(be_empty)
    end

    it "puts an airing on its day in the Paris time zone" do
      after_midnight = airing_at(friday + 1, 0, 30)

      expect(airings_of(friday)).to be_empty
      expect(airings_of(friday + 1)).to eq([ after_midnight ])
    end

    it "orders the airings of a day by time" do
      evening = airing_at(friday, 22)
      afternoon = airing_at(friday, 17, 30)

      expect(airings_of(friday)).to eq([ afternoon, evening ])
    end

    it "keeps the airings of the whole last day" do
      last_minute = airing_at(friday + 6, 23, 59)

      expect(airings_of(friday + 6)).to eq([ last_minute ])
    end

    it "leaves out what airs before the first day or after the last one" do
      airing_at(friday - 1, 23, 59)
      airing_at(friday + 7, 0, 0)

      expect(calendar.days.flat_map(&:airings)).to be_empty
    end

    it "leaves out an anime whose next airing is unknown" do
      create(:anime, next_airing_at: nil)

      expect(calendar.days.flat_map(&:airings)).to be_empty
    end
  end

  describe "a day" do
    it "knows whether it is today" do
      days = described_class.new(from: Date.current - 1).days

      expect(days.map(&:today?)).to eq([ false, true, false, false, false, false, false ])
    end
  end

  describe "#empty?" do
    it "is true when nothing airs in the seven days" do
      expect(calendar).to be_empty
    end

    it "is false as soon as an anime airs" do
      airing_at(friday + 3, 20)

      expect(calendar).not_to be_empty
    end
  end

  describe "#season and #year" do
    it "name the season of the first day" do
      expect(calendar.season).to eq("fall")
      expect(calendar.year).to eq(2026)
    end

    {
      Date.new(2027, 1, 5) => "winter",
      Date.new(2027, 4, 1) => "spring",
      Date.new(2027, 7, 31) => "summer",
      Date.new(2026, 12, 31) => "fall"
    }.each do |date, season|
      it "knows that #{date} is in the #{season} season" do
        expect(described_class.new(from: date).season).to eq(season)
      end
    end
  end
end
