class Sanitize
  class Whitelist

    def initialize(&block)
      @allowed_elements = {}
      @remove = []
      @transformers = []
      eval_block(&block)
      freeze
    end

    def freeze
      super
      @allowed_elements.freeze.values.each(&:freeze)
      @remove.freeze
      @transformers.freeze
    end

    def eval_block(&block)
      block.arity == 1 ? block.call(self) : instance_eval(&block) if block
    end

    def allow(elements)
      Array(elements).map { |name| element(name) }
    end

    def remove(boolean_or_elements)
      @remove_non_whitelisted = false
      @remove |= Array(boolean_or_elements)
    end

    def remove_non_whitelisted!
      @remove = []
      @remove_non_whitelisted = true
    end

    def escape_non_whitelisted!
      @remove_non_whitelisted = false
    end

    def element(name)
      @allowed_elements[name] ||= Sanitize::Whitelist::Element.new(name)
    end

    def transform(&block)
      @transformers << block
    end

    def to_h
      {}.tap do |result|
        result[:elements] = @allowed_elements.keys
        result[:remove_contents] = @remove_non_whitelisted unless @remove_non_whitelisted.nil?
        result[:remove_contents] = @remove unless @remove.empty?
        result[:transformers] = @transformers unless @transformers.empty?

        attributes = @allowed_elements.values.each_with_object({}) do |element,attrs|
          attrs.merge! element.to_h
        end
        result[:attributes] = attributes unless attributes.empty?

        protocols = @allowed_elements.values.each_with_object({}) do |element,attrs|
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
