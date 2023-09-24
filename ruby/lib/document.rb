require_relative 'tag.rb'

class Document

  def initialize(&proc)
    @root_tag = TagCreator.new(nil, (Proc.new &proc)).parent_tag
    # @tag_final = instance_exec &proc # Funciona igual
  end

  def xml
    @root_tag.xml
  end


  def self.serialize(object)
    Document.new &Document.automatic_proc([object])
  end

  def self.automatic_proc(objects)
    proc do
        objects.each { |object|
          send(object.class.to_s.downcase, object.normal_attributes_as_hash, &Document.automatic_proc(object.children)) # TODO: testear si es lo mismo pasarlo como bloque
        }
    end
  end
end



class TagCreator

  def initialize(parent_tag, input)
    @parent_tag = parent_tag
    contenido = interpretar(input)
    if contenido.normal?
      @parent_tag.with_child(contenido)
    end
  end

  def parent_tag
    @parent_tag
  end

  def interpretar(input)
    contenido = instance_eval &input
  end

  private def method_missing(name, *args, &block)
    tag = Tag.with_label(name)
    tag.with_attributes(args.empty? ? [] : args.first)
    unless @parent_tag.nil?
      @parent_tag.with_child(tag)
    else
      @parent_tag = tag
    end
    if block_given?
      TagCreator.new(tag, (Proc.new &block))
    end

  end




end

class Object
  def normal_attributes_as_hash
    atributos = Hash.new

    getters
      .select { |getter| normal_attribute?(getter) }
      .each { |msj| atributos[msj] = send(msj) }

    atributos
  end

  def getters
    instance_variables
      .map{ |atributo| atributo.to_s.delete_prefix('@') }
      .select{ |msj| respond_to? msj }
  end

  def normal_attribute?(getter)
    send(getter).normal?
  end

  def normal?
    normal_classes = [String, FalseClass, TrueClass, NilClass, Numeric]
    normal_classes.any?{ |normal_class| is_a? normal_class }
  end

  def children
    getters
      .select{|getter| !normal_attribute?(getter) }
      .flatten #[1,2,[3,4]] -> [1,2,3,4]
      .map{|getter| send(getter)}
  end
end

=begin

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

estado = Estado.new(3, 5, true)
alumno = Alumno.new("Matias","123456-8", "1234567890", estado)
documento = Document.serialize(alumno)
puts documento.xml
=end

documento = Document.new do
  alumno nombre: "Matias", legajo: "123456-7" do
    telefono { "1234567890" }
    estado es_regular: true do
      finales_rendidos { 3 }
      materias_aprobadas { 5 }
    end
  end
end

puts documento.xml



