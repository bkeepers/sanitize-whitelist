class Sanitize::Whitelist::Element
  attr_reader :name

  def initialize(name)
    @name = name
    @attributes = {}
    @allowed = true
  end

  def freeze
    super
    @attributes.values.each(&:freeze)
    @attributes.freeze
  end

  def allow!
    @allowed = true
  end

  def allowed?
    !!@allowed
  end

  def remove!
    @allowed = false
  end

  def remove?
    !@allowed
  end

  def allow(attributes)
    result = Array(attributes).map do |attr|
      @attributes[attr] = Sanitize::Whitelist::Attribute.new(attr)
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
