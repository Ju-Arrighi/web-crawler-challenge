class CrawlerController < ApplicationController
  def index
    all_entries = HackerNewsScraper.fetch

    @filter = params[:filter]

    @entries = case @filter
    when "long_titles"
      all_entries.select { |e| word_count(e.title) > 5 }
                 .sort_by { |e| -e.comments }
    when "short_titles"
      all_entries.select { |e| word_count(e.title) <= 5 }
                 .sort_by { |e| -e.points }
    else
      all_entries
    end
  end

  private

  def word_count(title)
    return 0 if title.blank?
    title.split.count { |token| token.match?(/[[:alnum:]]/) }
  end
end
