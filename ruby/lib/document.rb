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

class Alumno
  attr_reader :nombre, :legajo, :estado, :cositas
  def initialize(nombre, legajo, telefono, estado, cositas)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
    @cositas = cositas
  end
end

class Estado
  attr_reader :finales_rendidos, :materias_aprobadas, :es_regular
  def initialize(finales_rendidos, materias_aprobadas, es_regular)
    @finales_rendidos = finales_rendidos
    @es_regular = es_regular
    @materias_aprobadas = materias_aprobadas
  end
end

puts "\ndocumento_manual:\n"
documento_manual = Document.new do
  alumno nombre: "Matias", legajo: "123456-7" do
    telefono { "1234567890" }
    estado es_regular: true do
      finales_rendidos { 3 }
      materias_aprobadas { 5 }
    end
  end
end
puts documento_manual.xml

puts "\ndocumento_automatico:\n"
estado = Estado.new(3, 5, true) # TODO: No se pone en orden correcto, chequear implementación
alumno = Alumno.new("Matias","123456-8", "1234567890", estado, [1, estado])
documento_automatico = Document.serialize(alumno)
puts documento_automatico.xml