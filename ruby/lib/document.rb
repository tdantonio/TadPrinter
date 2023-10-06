
class Document
  attr_accessor :root_tag
  def initialize(&proc)
    if block_given?
      @root_tag = ContextEvaluator.new.instance_eval(&proc).first
    end
  end

  def xml
    @root_tag.xml
  end

  def self.serialize(object)
    Document.new.root_tag = object.to_tag
  end
end

