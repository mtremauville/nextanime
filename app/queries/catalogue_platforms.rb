# The platforms offered by the catalogue filter, each with its number of anime available in one
# country, plus the ones already selected so that they can always be unchecked.
class CataloguePlatforms
  Option = Data.define(:id, :name, :count)

  def initialize(country_code:, selected_ids: [])
    @country_code = country_code
    @selected_ids = selected_ids
  end

  def call
    StreamingPlatform.where(id: counts.keys | selected_ids)
                     .map { |platform| option_of(platform) }
                     .sort_by { |option| [ -option.count, option.name.downcase ] }
  end

  private

  attr_reader :country_code, :selected_ids

  def option_of(platform)
    Option.new(id: platform.id, name: platform.name, count: counts.fetch(platform.id, 0))
  end

  # An anime counts once for a platform, whatever the kinds of offer it has there.
  def counts
    @counts ||= StreamingAvailability.where(country_code: country_code)
                                     .group(:streaming_platform_id)
                                     .distinct
                                     .count(:anime_id)
  end
end
