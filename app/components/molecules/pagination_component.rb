module Molecules
  # Numbered pagination: previous, a short window of pages around the current one, next.
  # It knows nothing about routes: `url` turns a page number into a link.
  class PaginationComponent < ViewComponent::Base
    FIRST_PAGE = 1
    WINDOW_SIZE = 3

    def initialize(current:, total:, url:)
      @current = current
      @total = total
      @url = url
      super()
    end

    def render? = total > FIRST_PAGE

    private

    attr_reader :current, :total, :url

    def previous_number
      current - 1 if current > FIRST_PAGE
    end

    def next_number
      current + 1 if current < total
    end

    # The first page, the last page and the window around the current one,
    # with a gap wherever pages are left out.
    def items
      numbers = ([ FIRST_PAGE, total ] + window).uniq.sort
      numbers.each_with_object([]) do |number, result|
        result << :gap if result.last.is_a?(Integer) && number - result.last > 1
        result << number
      end
    end

    def window
      first = (current - 1).clamp(FIRST_PAGE, [ total - WINDOW_SIZE + 1, FIRST_PAGE ].max)
      (first...(first + WINDOW_SIZE)).select { |number| number <= total }
    end
  end
end
