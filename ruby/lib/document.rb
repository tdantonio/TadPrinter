require_relative 'tag.rb'

class Document
  attr_writer :root_tag
  def initialize(&proc)
    if block_given?
      @root_tag = ContextEvaluator.new.instance_eval(&proc).first
      # @root_tag = Document.root_tag(proc, :instance_eval)
    end
  end

  def xml
    @root_tag.xml
  end

  def self.serialize(object)
    Document.new.root_tag=(ContextEvaluator.new.serialize(object).first)
    # Document.new.root_tag=(root_tag(object, :serialize))
  end

  # Idea para evitar repetición de lógica(? ni idea, no estoy ni seguro de que la haya
  def self.root_tag(wachin, msj)
    ContextEvaluator.new.send(msj, wachin).first # no funciona pq instance_eval recibe un bloque, no un wachin
  end
end

class ContextEvaluator
  def initialize
    @tags = []
  end

  ###########
  # Punto 1 #
  ###########
  private def method_missing(name, *args, &proc)
    tag_children(name, args.empty? ? {} : args.first, ContextEvaluator.new.instance_eval(&proc))
  end

  def tag_children(label, attributes, possible_children)
    children = [possible_children].flatten # [1,2,[3,4]] -> [1,2,3,4]
    @tags << Tag.with_all(label, attributes, children)
  end

  ###########
  # Punto 2 #
  ###########
  def serialize(object)
    tag_children(object.label, object.primitive_attributes_as_hash, object_children(object.children))
  end

  def object_children(children)
    children.map do |child|
      ContextEvaluator.new.serialize(child)
    end
  end
end

class Object

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

  def label
    self.class.to_s.downcase
  end

  def children
    getters
      .select{|getter| !primitive_attribute?(getter) }
      .flatten #[1,2,[3,4]] -> [1,2,3,4]
      .map{|getter| send(getter)}
  end
end

class Alumno
  attr_reader :nombre, :legajo, :estado
  def initialize(nombre, legajo, telefono, estado)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
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

estado = Estado.new(3, 5, true) # TODO: No se pone en orden correcto, chequear implementación
alumno = Alumno.new("Matias","123456-8", "1234567890", estado)
documento_automatico = Document.serialize(alumno)
puts documento_automatico.xml