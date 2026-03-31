require "rails_helper"

# ---------------------------------------------------------------------------
# HackerNewsScraper::Entry — value object
# ---------------------------------------------------------------------------
RSpec.describe HackerNewsScraper::Entry do
  let(:valid_attrs) { { rank: 1, title: "Some Title", points: 42, comments: 7 } }

  it "is a Data subclass (immutable value object)" do
    expect(described_class.superclass).to eq(Data)
  end

  it "can be instantiated with all required fields" do
    entry = described_class.new(**valid_attrs)
    expect(entry.rank).to eq(1)
    expect(entry.title).to eq("Some Title")
    expect(entry.points).to eq(42)
    expect(entry.comments).to eq(7)
  end

  it "is frozen after creation" do
    expect(described_class.new(**valid_attrs)).to be_frozen
  end

  it "raises ArgumentError when a required field is missing" do
    expect { described_class.new(rank: 1, title: "X") }.to raise_error(ArgumentError)
  end

  it "raises ArgumentError when an unknown field is given" do
    expect { described_class.new(**valid_attrs, extra: "oops") }.to raise_error(ArgumentError)
  end

  it "considers two instances with identical fields equal" do
    expect(described_class.new(**valid_attrs)).to eq(described_class.new(**valid_attrs))
  end
end

# ---------------------------------------------------------------------------
# HackerNewsScraper
# ---------------------------------------------------------------------------
RSpec.describe HackerNewsScraper, type: :service do
  # Minimal HN-like HTML fixture
  def hn_html(entries)
    rows = entries.map.with_index(1) do |e, i|
      score_td = e[:points] ? %(<span class="score">#{e[:points]} points</span>) : ""
      comments_text = e[:comments] ? "#{e[:comments]}&nbsp;comments" : "discuss"
      <<~HTML
        <tr class="athing" id="#{i}">
          <td class="title"><span class="rank">#{i}.</span></td>
          <td class="title">
            <span class="titleline"><a href="#">#{e[:title]}</a></span>
          </td>
        </tr>
        <tr>
          <td class="subtext">
            #{score_td}
            <a href="#">flag</a>
            <a href="#">#{comments_text}</a>
          </td>
        </tr>
      HTML
    end
    "<html><body><table>#{rows.join}</table></body></html>"
  end

  let(:scraper) { described_class.new }

  # -------------------------------------------------------------------------
  # HTTP behaviour
  # -------------------------------------------------------------------------
  describe "HTTP behaviour" do
    it "fetches content from the correct HN URL" do
      expected_uri = URI(HackerNewsScraper::URL)
      fake_response = instance_double(Net::HTTPResponse, body: hn_html([
        { title: "Hello", points: 1, comments: 0 }
      ]))
      allow(Net::HTTP).to receive(:get_response).with(expected_uri).and_return(fake_response)

      described_class.fetch

      expect(Net::HTTP).to have_received(:get_response).with(expected_uri)
    end

    it "raises a descriptive error when the HTTP request fails" do
      allow(Net::HTTP).to receive(:get_response).and_raise(SocketError, "connection refused")

      expect { described_class.fetch }.to raise_error(RuntimeError, /Failed to fetch HackerNews/)
    end

    it "raises a descriptive error when the response raises an unexpected error" do
      allow(Net::HTTP).to receive(:get_response).and_raise(Errno::ECONNREFUSED)

      expect { described_class.fetch }.to raise_error(RuntimeError, /Failed to fetch HackerNews/)
    end
  end

  # -------------------------------------------------------------------------
  # parsing — quantity
  # -------------------------------------------------------------------------
  describe "parsing — quantity" do
    it "returns exactly 30 entries when the page has 30 or more rows" do
      html = hn_html(35.times.map { |i| { title: "Entry #{i}", points: i, comments: i } })
      entries = scraper.send(:parse, html)
      expect(entries.length).to eq(30)
    end
  end

  # -------------------------------------------------------------------------
  # parsing — data integrity
  # -------------------------------------------------------------------------
  describe "parsing — data integrity" do
    let(:html) do
      hn_html([
        { title: "First Entry",  points: 100, comments: 50 },
        { title: "Second Entry", points: 200, comments: 10 },
        { title: "Third Entry",  points: 300, comments: 99 }
      ])
    end
    let(:entries) { scraper.send(:parse, html) }

    it "returns Entry objects (correct type)" do
      expect(entries).to all(be_a(HackerNewsScraper::Entry))
    end

    it "correctly parses the entry number from the page" do
      expect(entries.map(&:rank)).to eq([ 1, 2, 3 ])
    end

    it "correctly parses the entry title from the page" do
      expect(entries.map(&:title)).to eq([ "First Entry", "Second Entry", "Third Entry" ])
    end

    it "correctly parses the entry points from the page" do
      expect(entries.map(&:points)).to eq([ 100, 200, 300 ])
    end

    it "correctly parses the number of comments from the page" do
      expect(entries.map(&:comments)).to eq([ 50, 10, 99 ])
    end
  end

  # -------------------------------------------------------------------------
  # parsing — edge cases
  # -------------------------------------------------------------------------
  describe "parsing — edge cases" do
    it "handles entries with 0 points gracefully (no crash)" do
      html = hn_html([ { title: "Zero Points", points: 0, comments: 5 } ])
      entry = scraper.send(:parse, html).first
      expect(entry.points).to eq(0)
    end

    it "handles entries with no comments ('discuss') gracefully" do
      html = hn_html([ { title: "No Comments", points: 10, comments: nil } ])
      entry = scraper.send(:parse, html).first
      expect(entry.comments).to eq(0)
    end

    it "does not return nil values for any entry attribute" do
      html = hn_html([
        { title: "Normal Entry", points: 42, comments: 7 },
        { title: "Zero Points",  points: 0,  comments: 0 }
      ])
      entries = scraper.send(:parse, html)
      entries.each do |entry|
        expect(entry.rank).not_to be_nil
        expect(entry.title).not_to be_nil
        expect(entry.points).not_to be_nil
        expect(entry.comments).not_to be_nil
      end
    end
  end
end
