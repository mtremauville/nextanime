class Molecules::NavItemComponent < ViewComponent::Base
  def initialize(label:, href:, icon:, current: false)
    @label = label
    @href = href
    @icon = icon
    @current = current
  end

  def call
    link_to @href, class: css_classes, aria: { current: current_value } do
      safe_join([ icon_tag, label_tag ])
    end
  end

  private

  def icon_tag
    tag.i(class: "bi bi-#{@icon}", aria: { hidden: true })
  end

  def label_tag
    tag.span(@label, class: "na-nav__label")
  end

  def css_classes
    class_names("na-nav__link", "na-nav__link--active": @current)
  end

  def current_value
    "page" if @current
  end
end
