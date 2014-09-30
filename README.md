# Sanitize::Whitelist

Objects to represent a whitelist that can be used by the sanitize gem.

Problem: the `sanitize` gem uses a deeply nested hash to configure sanitization. It is cumbersome to inherit and modify sanitization configuration without modifying the original hash.

This wraps it with real objects, which means:

- The entire whitelist is frozen after the yielded block.
- #dup behaves as expected and returns a deep clone
- #to_hash creates a hash that can be passed to the sanitize gem

## Installation

Add this line to your application's Gemfile:

    gem 'sanitize-whitelist'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sanitize-whitelist

## Usage

```ruby
Whitelist.new do
  # Explicitly declare elements that are allowed.
  allow %w(
    h1 h2 h3 h4 h5 h6 h7 h8 br b i strong em a pre code img tt
    div ins del sup sub p ol ul table thead tbody tfoot blockquote
    dl dt dd kbd q samp var hr ruby rt rp li tr td th s strike
  )

  # Elements to completely remove instead of escape.
  remove "script"

  # Allow href and src attributes, and specify the protocols that they can use.
  element("a").allow("href").protocols('http', 'https', 'mailto', :relative, 'github-windows', 'github-mac')
  element("img").allow("src").protocols('http', 'https', :relative)

  # Allow other elements on divs
  element("div").allow %w(itemscope itemtype)

  # All elements can have these attributes
  element(:all).allow %w(
    abbr accept accept-charset accesskey action align alt axis border
    cellpadding cellspacing char charoff charset checked cite clear cols
    colspan color compact coords datetime dir disabled enctype for frame
    headers height hreflang hspace ismap label lang longdesc maxlength media
    method multiple name nohref noshade nowrap prompt readonly rel rev rows
    rowspan rules scope selected shape size span start summary tabindex target
    title type usemap valign value vspace width itempro
  )

  # Top-level <li> elements are removed because they can break out of
  # containing markup.
  transform do |env|
    name, node = env[:node_name], env[:node]
    if name == "li" && !node.ancestors.any?{ |n| %w(ul ol).include?(n.name) }
      node.replace(node.children)
    end
  end

  # Table child elements that are not contained by a <table> are removed.
  # Otherwise they can be used to break out of containing markup.
  transform do |env|
    name, node = env[:node_name], env[:node]
    if (%w(thead tbody tfoot).include?(name) || %w(tr td th).include?(name)) && !node.ancestors.any? { |n| n.name == "table" }
      node.replace(node.children)
    end
  end
end
```

## Contributing

1. Fork it ( https://github.com/bkeepers/sanitize-whitelist/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
