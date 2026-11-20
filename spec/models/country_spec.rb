require "rails_helper"

RSpec.describe Country do
  describe "CODES" do
    it "lists the supported countries, France first" do
      expect(described_class::CODES).to eq(%w[FR BE CH CA US GB])
    end
  end

  describe "DEFAULT" do
    it "is France" do
      expect(described_class::DEFAULT).to eq("FR")
    end
  end

  describe ".supported?" do
    it "accepts the code of a supported country" do
      expect(described_class.supported?("BE")).to be(true)
    end

    it "refuses a country that is not supported" do
      expect(described_class.supported?("JP")).to be(false)
    end

    it "refuses a code that is not in capitals" do
      expect(described_class.supported?("fr")).to be(false)
    end

    it "refuses nothing" do
      expect(described_class.supported?(nil)).to be(false)
    end
  end

  describe ".name_for" do
    it "gives the name of the country in French" do
      expect(described_class.name_for("CH")).to eq("Suisse")
    end

    it "fails for a country that is not supported" do
      expect { described_class.name_for("JP") }.to raise_error(KeyError)
    end
  end
end
