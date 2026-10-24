class StyleguideController < ApplicationController
  COLOR_TOKENS = %w[
    --na-bg --na-surface --na-surface-2 --na-border
    --na-text --na-muted --na-magenta --na-cyan
  ].freeze

  def show
    @color_tokens = COLOR_TOKENS
  end
end
