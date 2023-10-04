class Document
  attr_writer :root_tag
  def initialize(&proc)
    if block_given?
      @root_tag = ContextEvaluator.new.tag_proc(proc).first
    end
  end

  def xml
    @root_tag.xml
  end

  def self.serialize(object)
    Document.new.root_tag=(object.to_tag)
  end
end

