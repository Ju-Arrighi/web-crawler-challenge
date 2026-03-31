require "rails_helper"

RSpec.describe CrawlerController, type: :request do
  def build_entry(rank, title, points, comments)
    HackerNewsScraper::Entry.new(rank: rank, title: title, points: points, comments: comments)
  end

  # ---------------------------------------------------------------------------
  # word_count — core rules
  # ---------------------------------------------------------------------------
  describe "#word_count" do
    let(:ctrl) { described_class.new }

    it "counts simple spaced words correctly" do
      expect(ctrl.send(:word_count, "Hello World")).to eq(2)
    end

    it "counts a title with exactly 5 words correctly" do
      expect(ctrl.send(:word_count, "One two three four five")).to eq(5)
    end

    it "excludes standalone symbols / punctuation" do
      expect(ctrl.send(:word_count, "This is - a test")).to eq(4)
    end

    it "treats hyphenated words as a single word" do
      expect(ctrl.send(:word_count, "self-explained")).to eq(1)
    end

    it "excludes leading and trailing spaces" do
      expect(ctrl.send(:word_count, "  hello world  ")).to eq(2)
    end

    it "handles titles with numbers" do
      expect(ctrl.send(:word_count, "Top 10 stories")).to eq(3)
    end

    it "handles a title with only symbols" do
      expect(ctrl.send(:word_count, "- -- ---")).to eq(0)
    end

    it "handles an empty title" do
      expect(ctrl.send(:word_count, "")).to eq(0)
    end
  end

  # ---------------------------------------------------------------------------
  # filtering classification
  # ---------------------------------------------------------------------------
  describe "filtering classification" do
    let(:entry_with) { ->(title) { build_entry(1, title, 10, 5) } }

    before { allow(HackerNewsScraper).to receive(:fetch).and_return([]) }

    it "long_titles includes an entry when word_count > 5" do
      e = entry_with.("How I built a Rails app from scratch")  # 8 words
      allow(HackerNewsScraper).to receive(:fetch).and_return([ e ])
      get root_path, params: { filter: "long_titles" }
      expect(assigns(:entries)).to include(e)
    end

    it "long_titles excludes an entry when word_count == 5" do
      e = entry_with.("One two three four five")
      allow(HackerNewsScraper).to receive(:fetch).and_return([ e ])
      get root_path, params: { filter: "long_titles" }
      expect(assigns(:entries)).not_to include(e)
    end

    it "short_titles includes an entry when word_count == 5" do
      e = entry_with.("One two three four five")
      allow(HackerNewsScraper).to receive(:fetch).and_return([ e ])
      get root_path, params: { filter: "short_titles" }
      expect(assigns(:entries)).to include(e)
    end

    it "short_titles includes an entry when word_count < 5" do
      e = entry_with.("Buy low sell high")  # 4 words
      allow(HackerNewsScraper).to receive(:fetch).and_return([ e ])
      get root_path, params: { filter: "short_titles" }
      expect(assigns(:entries)).to include(e)
    end
  end

  # ---------------------------------------------------------------------------
  # HTTP request tests
  # ---------------------------------------------------------------------------
  let(:short1) { build_entry(1, "Buy low sell high",                          80,   5) }
  let(:short2) { build_entry(2, "AI is overhyped",                           150,   3) }
  let(:long1)  { build_entry(3, "How I built a side project in two weeks",    30,  90) }
  let(:long2)  { build_entry(4, "Understanding neural nets from scratch today", 10, 200) }
  let(:blank)  { build_entry(5, "",                                          999, 999) }
  let(:all_entries) { [ short1, short2, long1, long2, blank ] }

  before { allow(HackerNewsScraper).to receive(:fetch).and_return(all_entries) }

  describe "GET /" do
    it "returns HTTP 200" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "exposes all entries unfiltered" do
      get root_path
      expect(assigns(:entries)).to eq(all_entries)
    end

    it "sets @filter to nil" do
      get root_path
      expect(assigns(:filter)).to be_nil
    end
  end

  describe "GET /?filter=long_titles" do
    before { get root_path, params: { filter: "long_titles" } }

    it "returns HTTP 200" do
      expect(response).to have_http_status(:ok)
    end

    it "includes only entries with more than 5 words in the title" do
      expect(assigns(:entries)).to contain_exactly(long1, long2)
    end

    it "sorts by comments descending" do
      expect(assigns(:entries).map(&:comments)).to eq([ 200, 90 ])
    end

    it "sets @filter to 'long_titles'" do
      expect(assigns(:filter)).to eq("long_titles")
    end
  end

  describe "GET /?filter=short_titles" do
    before { get root_path, params: { filter: "short_titles" } }

    it "returns HTTP 200" do
      expect(response).to have_http_status(:ok)
    end

    it "includes only entries with 5 or fewer words in the title" do
      expect(assigns(:entries)).to contain_exactly(short1, short2, blank)
    end

    it "sorts by points descending" do
      expect(assigns(:entries).map(&:points)).to eq([ 999, 150, 80 ])
    end

    it "treats a blank title as a short title (word_count == 0)" do
      expect(assigns(:entries)).to include(blank)
    end

    it "sets @filter to 'short_titles'" do
      expect(assigns(:filter)).to eq("short_titles")
    end
  end

  describe "GET /?filter=unknown" do
    it "falls through to unfiltered and returns all entries" do
      get root_path, params: { filter: "unknown" }
      expect(assigns(:entries)).to eq(all_entries)
    end
  end
end
