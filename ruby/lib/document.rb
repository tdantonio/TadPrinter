require_relative 'tag.rb'
require_relative 'contextEvaluator'
require_relative 'annotator'
require_relative 'annotations'

class Document
  attr_writer :root_tag
  def initialize(&proc)
    if block_given?
      @root_tag = Document.root_tag(proc)
    end
  end

  def xml
    @root_tag.xml
  end

  def self.serialize(object)
    Document.new.root_tag=(root_tag(object))
  end

  def self.root_tag(wachin)
    tipo = wachin.is_a?(Proc) ? "proc" : "object" # Me la compliqué al pedo pero qsy (no funciona simplemente con wachin.label)
    serializer_msj = "tag_" + tipo
    ContextEvaluator.new.send(serializer_msj, wachin).first
  end
end

######################
# Espacio de pruebas #
######################
✨Label✨("falopA")
class A
end

C = Class.new
D = Object.new
class B
end

A.evaluate_annotations

puts "A.new.label: #{A.new.label}"
puts "B.new.label: #{B.new.label}"
puts "C.new.label: #{C.new.label}"