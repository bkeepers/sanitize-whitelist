require "spec_helper"

describe Sanitize::Whitelist do
  let(:whitelist) { Sanitize::Whitelist.new }
  describe "allow" do
    it "allows nothing by default" do
      expect(whitelist.to_h).to eq({:elements => []})
    end

    it "adds a single element" do
      whitelist.allow "div"
      expect(whitelist.to_h).to eq({:elements => ["div"]})
    end

    it "adds an array of elements" do
      whitelist.allow %w(div p)
      expect(whitelist.to_h).to eq({:elements =>  %w(div p)})
    end

    it "adds multiple calls" do
      whitelist.allow "p"
      whitelist.allow "a"
      expect(whitelist.to_h).to eq({:elements =>  %w(p a)})
    end
  end

  describe "remove" do
    it "adds a single element" do
      whitelist.remove "script"
      expect(whitelist.to_h).to eq({:remove_contents =>  %w(script), :elements => []})
    end

    it "adds an array of elements" do
      whitelist.remove %w(script object)
      expect(whitelist.to_h).to eq({:remove_contents =>  %w(script object), :elements => []})
    end
  end

  describe "remove_non_whitelisted!" do
    it "sets remove_contents to true" do
      whitelist.remove_non_whitelisted!
      expect(whitelist.to_h).to eq({:remove_contents => true, :elements => []})
    end
  end

  describe "element#allow" do
    it "adds a single attribute" do
      whitelist.element("a").allow("href")
      expect(whitelist.to_h).to eq({:elements => ["a"], :attributes => {"a" => ["href"]}})
    end
  end

  describe "attribute#protocols" do
    it "adds a single protocol" do
      whitelist.element("a").allow("href").protocols("https")
      expect(whitelist.to_h).to eq({
        :protocols => {"a" => {"href" => ["https"]}},
        :elements => ["a"], :attributes => {"a" => ["href"]}
      })
    end

    it "adds multiple protocols" do
      whitelist.element("a").allow("href").protocols(%w(http https ftp))
      expect(whitelist.to_h).to eq({
        :protocols => {"a" => {"href" => %w(http https ftp)}},
        :elements => ["a"], :attributes => {"a" => ["href"]}
      })
    end
  end

  describe "transform" do
    it "adds block to transformers" do
      block = lambda { }
      whitelist.transform(&block)
      expect(whitelist.to_h).to eq({:transformers => [block], :elements => []})
    end
  end
end
