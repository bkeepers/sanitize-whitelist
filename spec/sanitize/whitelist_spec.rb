require "spec_helper"

describe Sanitize::Whitelist do
  describe "initialize" do
    it "instance_evals block with arity of 0" do
      whitelist = Sanitize::Whitelist.new { allow "div" }
      expect(whitelist.to_hash).to eq({:elements => ["div"]})
    end

    it "yields with self as arg if arity of 1" do
      self_in_block = nil
      arg_in_block = nil
      whitelist = Sanitize::Whitelist.new do |w|
        w.allow "div"
        arg_in_block = w
        self_in_block = self
      end
      expect(whitelist.to_hash).to eq({:elements => ["div"]})
      expect(arg_in_block).to be(whitelist)
      expect(self_in_block).to be(self)
    end

    it "freezes elements after initialization" do
      whitelist = Sanitize::Whitelist.new do
        allow "div"
        element("a").allow("href")
      end
      expect { whitelist.allow("p") }.to raise_error(RuntimeError, /frozen/)
      expect { whitelist.element("div").allow("class") }.to raise_error(RuntimeError, /frozen/)
      expect { whitelist.element("a").allow("href").protocols("http") }.to raise_error(RuntimeError, /frozen/)
    end
  end

  describe "allow" do
    it "allows nothing by default" do
      whitelist = Sanitize::Whitelist.new
      expect(whitelist.to_hash).to eq({:elements => []})
    end

    it "adds a single element" do
      whitelist = Sanitize::Whitelist.new { allow "div" }
      expect(whitelist.to_hash).to eq({:elements => ["div"]})
    end

    it "adds an array of elements" do
      whitelist = Sanitize::Whitelist.new { allow %w(div p) }
      expect(whitelist.to_hash).to eq({:elements =>  %w(div p)})
    end

    it "adds multiple calls" do
      whitelist = Sanitize::Whitelist.new do
        allow "p"
        allow "a"
      end
      expect(whitelist.to_hash).to eq({:elements =>  %w(p a)})
    end
  end

  describe "remove" do
    it "adds a single element" do
      whitelist = Sanitize::Whitelist.new { remove "script" }
      expect(whitelist.to_hash).to eq({:remove_contents =>  %w(script), :elements => []})
    end

    it "adds an array of elements" do
      whitelist = Sanitize::Whitelist.new { remove %w(script object) }
      expect(whitelist.to_hash).to eq({:remove_contents =>  %w(script object), :elements => []})
    end
  end

  describe "remove_non_whitelisted!" do
    it "sets remove_contents to true" do
      whitelist = Sanitize::Whitelist.new { remove_non_whitelisted! }
      expect(whitelist.to_hash).to eq({:remove_contents => true, :elements => []})
    end
  end

  describe "element#allow" do
    it "adds a single attribute" do
      whitelist = Sanitize::Whitelist.new { element("a").allow("href") }
      expect(whitelist.to_hash).to eq({:elements => ["a"], :attributes => {"a" => ["href"]}})
    end
  end

  describe "attribute#protocols" do
    it "adds a single protocol" do
      whitelist = Sanitize::Whitelist.new { element("a").allow("href").protocols("https") }
      expect(whitelist.to_hash).to eq({
        :protocols => {"a" => {"href" => ["https"]}},
        :elements => ["a"], :attributes => {"a" => ["href"]}
      })
    end

    it "adds multiple protocols" do
      whitelist = Sanitize::Whitelist.new do
        element("a").allow("href").protocols(%w(http https ftp))
      end
      expect(whitelist.to_hash).to eq({
        :protocols => {"a" => {"href" => %w(http https ftp)}},
        :elements => ["a"], :attributes => {"a" => ["href"]}
      })
    end

    it "accepts empty protocols" do
      whitelist = Sanitize::Whitelist.new do
        element("a").allow("href").protocols([])
      end
      expect(whitelist.to_hash).to eq({
        :protocols => {"a" => {"href" => []}},
        :elements => ["a"], :attributes => {"a" => ["href"]}
      })
    end
  end

  describe "transform" do
    it "adds block to transformers" do
      block = lambda { }
      whitelist = Sanitize::Whitelist.new { transform(&block) }
      expect(whitelist.to_hash).to eq({:transformers => [block], :elements => []})
    end
  end

  describe "dup" do
    let(:whitelist) { Sanitize::Whitelist.new { allow "p" } }

    it "dups elements" do
      dup = whitelist.dup { allow "div" }
      expect(dup.to_hash).to eq({:elements => ["p", "div"]})
      expect(whitelist.to_hash).to eq({:elements => ["p"]})
    end

    it "does not remove from original" do
      dup = whitelist.dup { remove "p" }
      expect(dup.to_hash).to eq({:elements => [], :remove_contents => ["p"]})
      expect(whitelist.to_hash).to eq({:elements => ["p"]})
    end

    it "dups attributes" do
      dup = whitelist.dup { element("p").allow("class") }
      expect(dup.to_hash).to eq({:elements => ["p"], :attributes => {"p" => ["class"]}})
      expect(whitelist.to_hash).to eq({:elements => ["p"]})
    end

    it "dups protocols" do
      whitelist = Sanitize::Whitelist.new { element("a").allow("href").protocols("ftp") }
      dup = whitelist.dup { element("a").allow("href").protocols("https") }

      expect(dup.to_hash).to eq({
        :elements => ["a"],
        :attributes => {"a" => ["href"]},
        :protocols => {"a" => {"href" => ["https"]}}
      })
      expect(whitelist.to_hash).to eq({
        :elements => ["a"],
        :attributes => {"a" => ["href"]},
        :protocols => {"a" => {"href" => ["ftp"]}}
      })
    end
  end
end
