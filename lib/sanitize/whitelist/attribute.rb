class Sanitize::Whitelist::Attribute
  def initialize(name)
    @name = name
  end

  def protocols(protocols)
    @protocols = Array(protocols)
  end

  def to_h
    @protocols ? {@name => @protocols} : {}
  end

  def freeze
    super
    @protocols.freeze if @protocols
  end
end
