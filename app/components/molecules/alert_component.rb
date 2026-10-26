module Molecules
  class AlertComponent < ViewComponent::Base
    DEFAULT_VARIANT = :notice
    VARIANTS = {
      notice: { modifier: "success", role: "status", icon: "check-circle" },
      alert: { modifier: "danger", role: "alert", icon: "exclamation-circle" }
    }.freeze

    def initialize(message:, variant: DEFAULT_VARIANT)
      raise ArgumentError, "Unknown alert variant: #{variant.inspect}" unless VARIANTS.key?(variant.to_sym)

      @message = message
      @variant = variant.to_sym
    end

    private

    attr_reader :message

    def settings
      VARIANTS.fetch(@variant)
    end
  end
end
