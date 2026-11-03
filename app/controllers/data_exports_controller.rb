class DataExportsController < ApplicationController
  before_action :authenticate_user!

  def show
    response.headers["Cache-Control"] = "no-store"
    send_data export_json, type: :json, disposition: :attachment, filename: export_filename
  end

  private

  def export_json
    JSON.pretty_generate(UserDataExport.new(current_user).call)
  end

  def export_filename
    "nextanime-donnees-#{Date.current.iso8601}.json"
  end
end
