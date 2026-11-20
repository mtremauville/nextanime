module MetaTagsHelper
  SITE_NAME = "NextAnime".freeze
  TITLE_SEPARATOR = " · ".freeze
  DEFAULT_DESCRIPTION = "Swipe tes références, NextAnime cerne ta vibe et te propose des anime qui te ressemblent, pas ceux que tout le monde regarde.".freeze
  SHARED_IMAGE_PATH = "/og-image.png".freeze

  def page_title
    safe_join([ content_for(:title).presence, SITE_NAME ].compact, TITLE_SEPARATOR)
  end

  def page_description
    content_for(:description).presence || DEFAULT_DESCRIPTION
  end

  # Without the query: the filters of the catalogue share the address of the catalogue.
  def page_url
    "#{request.base_url}#{request.path}"
  end

  def shared_image_url
    "#{request.base_url}#{SHARED_IMAGE_PATH}"
  end
end
