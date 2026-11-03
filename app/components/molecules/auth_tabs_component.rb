module Molecules
  class AuthTabsComponent < ViewComponent::Base
    LABELS = { sign_in: "Connexion", sign_up: "Créer un compte" }.freeze

    def initialize(current:)
      raise ArgumentError, "Unknown tab: #{current.inspect}" unless LABELS.key?(current)

      @current = current
      super()
    end

    private

    def tabs
      {
        sign_in: new_user_session_path,
        sign_up: new_user_registration_path
      }.map { |key, href| [ key, LABELS.fetch(key), href ] }
    end

    def current?(key)
      key == @current
    end
  end
end
