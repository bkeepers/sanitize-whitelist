class Sanitize::Whitelist::Attribute
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

  def freeze
    super
    @protocols.freeze
  end
end
