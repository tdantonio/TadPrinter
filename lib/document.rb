class Document
  attr_accessor :root_tag
  def initialize(&proc)
    @root_tag = ContextEvaluator.new.instance_eval(&proc).first
  end

  def xml
    @root_tag.xml
  end

  def self.serialize(object)
    object.to_tag
  end
end

