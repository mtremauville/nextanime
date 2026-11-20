# Be sure to restart your server when you modify this file.

# Content security policy of the app.
# See https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src :self
    policy.style_src :self, "https://fonts.googleapis.com"
    policy.font_src :self, "https://fonts.gstatic.com", :data
    # The covers and banners come from AniList, the logos of the platforms from TMDB.
    policy.img_src :self, "https://s4.anilist.co", "https://image.tmdb.org", :data
    policy.connect_src :self
    policy.object_src :none
    policy.base_uri :self
    policy.form_action :self
    policy.frame_ancestors :none
  end

  # The importmap tags are inline scripts: they carry the nonce of the session.
  config.content_security_policy_nonce_generator = ->(request) { request.session[:csp_nonce] ||= SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
