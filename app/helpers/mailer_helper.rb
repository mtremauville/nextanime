# Mail clients ignore CSS custom properties and stylesheets, so the dark theme
# tokens of app/assets/stylesheets/tokens/_colors.scss are repeated here as
# literals and exposed as inline styles. Keep both files in sync.
module MailerHelper
  COLORS = {
    background: "#0B0A14",
    surface: "#14122A",
    border: "#2C2A55",
    text: "#F2F0FF",
    muted: "#A9A6D0",
    magenta: "#FF2E93",
    cyan: "#19E3F2",
    on_magenta: "#0B0A14"
  }.freeze

  FONT_STACK = "Manrope, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif".freeze

  STYLES = {
    body: "margin:0;padding:0;background-color:#{COLORS[:background]};font-family:#{FONT_STACK};",
    brand: "padding:0 8px 24px;font-family:#{FONT_STACK};font-size:22px;font-weight:800;color:#{COLORS[:text]};",
    brand_mark: "color:#{COLORS[:magenta]};",
    card: "background-color:#{COLORS[:surface]};border:1px solid #{COLORS[:border]};border-radius:16px;" \
          "padding:36px 32px;font-family:#{FONT_STACK};color:#{COLORS[:text]};",
    heading: "margin:0 0 16px;font-size:26px;line-height:1.25;font-weight:800;color:#{COLORS[:text]};",
    paragraph: "margin:0 0 16px;font-size:16px;line-height:1.6;color:#{COLORS[:text]};",
    muted: "margin:0 0 8px;font-size:14px;line-height:1.6;color:#{COLORS[:muted]};",
    note: "margin:28px 0 0;padding-top:20px;border-top:1px solid #{COLORS[:border]};" \
          "font-size:14px;line-height:1.6;color:#{COLORS[:muted]};",
    button_cell: "border-radius:12px;background-color:#{COLORS[:magenta]};",
    button: "display:inline-block;padding:16px 28px;font-family:#{FONT_STACK};font-size:16px;font-weight:800;" \
            "line-height:1;color:#{COLORS[:on_magenta]};text-decoration:none;border-radius:12px;",
    link: "font-size:14px;line-height:1.6;color:#{COLORS[:cyan]};word-break:break-all;",
    footer: "padding:24px 8px 0;font-family:#{FONT_STACK};font-size:12px;line-height:1.6;color:#{COLORS[:muted]};"
  }.freeze

  def mail_color(name)
    COLORS.fetch(name)
  end

  def mail_style(name)
    STYLES.fetch(name)
  end
end
