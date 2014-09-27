require "sanitize/whitelist/version"

class Sanitize
  class Whitelist
    class Element
      def initialize(name)
        @name = name
        @attributes = {}
      end

      def allow(attributes)
        result = Array(attributes).map do |attr|
          @attributes[attr] = Attribute.new(attr)
        end
        result.size == 1 ? result.first : result
      end

      def to_h
        @attributes.empty? ? {} : {@name => @attributes.keys}
      end

      def to_protocols_hash
        @attributes.values.each_with_object({}) do |attribute, result|
          result.merge! @name => attribute.to_h unless attribute.to_h.empty?
        end
      end
    end

    class Attribute
      def initialize(name)
        @name = name
        @protocols = []
      end

      def protocols(protocols)
        @protocols |= Array(protocols)
      end

      def to_h
        @protocols.empty? ? {} : {@name => @protocols}
      end
    end

    def initialize
      @allowed_elements = {}
      @remove = []
    end

    def allow(elements)
      Array(elements).each do |name|
        @allowed_elements[name] ||= Element.new(name)
      end
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

    def [](name)
      @allowed_elements[name] ||= Element.new(name)
    end

    def to_h
      {}.tap do |result|
        result[:elements] = @allowed_elements.keys
        result[:remove_contents] = @remove_non_whitelisted unless @remove_non_whitelisted.nil?
        result[:remove_contents] = @remove unless @remove.empty?

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

