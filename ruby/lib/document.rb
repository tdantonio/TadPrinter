require_relative 'tag.rb'

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

class ContextEvaluator
  def initialize
    @tags = []
  end

  ###########
  # Punto 1 #
  ###########
  def tag_proc(proc) # Solo sirve de pasamano para que :root_tag pueda recibirlo como un objeto también.
    instance_eval(&proc)
  end
  private def method_missing(name, *args, &proc)
    attributes = args.empty? ? {} : args.first
    children_tags = ContextEvaluator.new.instance_eval(&proc)
    tag_with_children(name, attributes, children_tags)
  end

  def tag_with_children(label, attributes, possible_children_tags)
    children_tags = [possible_children_tags].flatten # [1,2,[3,4,[5]]] -> [1,2,3,4,5]
    @tags << Tag.with_everything(label, attributes, children_tags)
    # Si tiene más de un hijo, para los primeros se ignora el retorno, pero los va guardando en la lista.
    # Solo devuelve la lista de tags cuando está completa, es decir, para el último hijo.
  end

  ###########
  # Punto 2 #
  ###########
  def tag_object(object) # Al principio lo había llamado solo :tag, pero entonces no tenía un buen nombre para :tag_proc (que antes era :evaluate).
    children_tags = tag_all(object.children)
    tag_with_children(object.label, object.primitive_attributes_as_hash, children_tags)
  end

  def tag_all(children)
    children.map do |child|
      child.primitive? ? child : ContextEvaluator.new.tag_object(child)
    end
  end
end

class Object
  def label
    self.class.to_s.downcase
  end

  def primitive_attributes_as_hash
    atributos = Hash.new

    getters
      .select { |getter| primitive_attribute?(getter) }
      .each { |msj| atributos[msj] = send(msj) }

    atributos
  end

  def getters
    instance_variables
      .map{ |atributo| atributo.to_s.delete_prefix('@') }
      .select{ |msj| respond_to? msj }
  end

  def primitive_attribute?(getter)
    send(getter).primitive?
  end

  def primitive?
    primitive_classes = [String, FalseClass, TrueClass, NilClass, Numeric]
    primitive_classes.any?{ |primitive_class| is_a? primitive_class }
  end

  def children
    getters
      .select{ |getter| !primitive_attribute?(getter) }
      .map{ |getter| send(getter) }
      .flatten #[1,2,[3,4]] -> [1,2,3,4]
  end
end

def method_missing(annotation_name, *args)
  if annotation_name.match? "✨.*✨"
    Object.const_get(annotation_name.to_s.gsub('✨','')).new(*args) # TODO: falta lanzar un error más descriptivo en caso de que no matchee con ninguna clase existente
  else
    super(annotation_name, *args) # warning: redefining Object#method_missing may cause infinite loop
  end
end

class Annotator # Tiene que definirse antes de extender a Class
  @pending_annotations = []
  def self.add_pending_annotation(annotation)
    @pending_annotations << annotation
  end

  def self.add_pending_annotations_to(clase)
    clase.add_annotations(@pending_annotations)
    @pending_annotations = []
  end
end

class Class
  def inherited(subclass)
    Annotator.add_pending_annotations_to(subclass)
  end

  def add_annotations(annotations)
    @annotations = annotations
  end

  def evaluate_annotations
    @annotations.each do |annotation|
      annotation.evaluate(self)
    end
  end
end

class Label
  def initialize(label)
    @label = label
    Annotator.add_pending_annotation(self)
  end

  def evaluate(clase)
    label = @label # TODO: Hardcodeado nashe
    clase.define_method(:label) { label }
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