class Sanitize
  class Whitelist

    def initialize(&block)
      @elements = {}
      @transformers = []
      eval_block(&block)
      freeze
    end

    def freeze
      super
      @elements.freeze.values.each(&:freeze)
      @transformers.freeze
    end

    def eval_block(&block)
      block.arity == 1 ? block.call(self) : instance_eval(&block) if block
    end

    def allow(elements)
      Array(elements).map { |name| element(name) }
    end

    def remove(boolean_or_elements)
      Array(boolean_or_elements).map { |name| element(name).remove! }
    end

    def remove_non_whitelisted!
      @remove_non_whitelisted = true
    end

    def escape_non_whitelisted!
      @remove_non_whitelisted = false
    end

    def element(name)
      @elements[name] ||= Sanitize::Whitelist::Element.new(name)
    end

    def transform(&block)
      @transformers << block
    end

    def allowed_elements
      @elements.values.select(&:allowed?)
    end

    def remove_elements
      @elements.values.select(&:remove?)
    end

    def to_h
      {}.tap do |result|
        result[:elements] = allowed_elements.map(&:name)

        if @remove_non_whitelisted
          result[:remove_contents] = @remove_non_whitelisted
        else
          elements = remove_elements.map(&:name)
          result[:remove_contents] = elements unless elements.empty?
        end

        result[:transformers] = @transformers unless @transformers.empty?

        attributes = allowed_elements.each_with_object({}) do |element,attrs|
          attrs.merge! element.to_h
        end
        result[:attributes] = attributes unless attributes.empty?

        protocols = allowed_elements.each_with_object({}) do |element,attrs|
          attrs.merge! element.to_protocols_hash
        end
        result[:protocols] = protocols unless protocols.empty?
      end
    end
  end
end

require "sanitize/whitelist/version"
require "sanitize/whitelist/attribute"
require "sanitize/whitelist/element"
