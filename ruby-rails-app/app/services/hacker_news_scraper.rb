require "net/http"
require "nokogiri"

class HackerNewsScraper
  URL = "https://news.ycombinator.com/"
  ENTRY_LIMIT = 30

  Entry = Data.define(:rank, :title, :points, :comments)

  def self.fetch
    new.fetch
  end

  def fetch
    html = get(URL)
    parse(html)
  end

  private

  def get(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    response.body
  end

  def parse(html)
    doc = Nokogiri::HTML(html)
    entries = []

    doc.css("tr.athing").first(ENTRY_LIMIT).each do |row|
      rank  = row.at_css(".rank")&.text&.delete(".")&.to_i
      title = row.at_css(".titleline > a")&.text&.strip

      subtext = row.next_element
      points   = subtext&.at_css(".score")&.text&.scan(/\d+/)&.first&.to_i || 0
      comments = subtext&.css("a")&.last&.text&.scan(/\d+/)&.first&.to_i || 0

      entries << Entry.new(rank:, title:, points:, comments:)
    end

    entries
  end
end
