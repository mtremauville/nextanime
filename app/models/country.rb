# The countries where the availabilities of the streaming platforms are known, and the one that is
# used until the visitor chooses another.
module Country
  NAMES = {
    "FR" => "France",
    "BE" => "Belgique",
    "CH" => "Suisse",
    "CA" => "Canada",
    "US" => "États-Unis",
    "GB" => "Royaume-Uni"
  }.freeze
  CODES = NAMES.keys.freeze
  DEFAULT = "FR".freeze

  def self.supported?(code) = NAMES.key?(code)

  def self.name_for(code) = NAMES.fetch(code)
end
