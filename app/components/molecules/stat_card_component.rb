module Molecules
  class StatCardComponent < ViewComponent::Base
    def initialize(stat:, value:, label:, tone: :default)
      @stat = stat
      @value = value
      @label = label
      @tone = tone
    end

    private

    attr_reader :stat, :value, :label, :tone
  end
end
