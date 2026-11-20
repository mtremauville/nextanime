require "capybara/selenium/driver"

# Capybara 3.40.0 resets Chrome with Storage.clearDataForOrigin and the origin "*", which Chrome 158
# refuses ("* is not a valid URL"). The origin of the application server is the only one the tests
# visit, so it is cleared instead.
module ChromeStorageReset
  private

  def execute_cdp(command, params = {})
    params = params.merge(origin: app_origin) if command == "Storage.clearDataForOrigin" && params[:origin] == "*"
    super
  end

  def app_origin
    server = Capybara.current_session.server
    server ? "http://#{server.host}:#{server.port}" : "*"
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageReset)
