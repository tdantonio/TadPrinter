require_relative 'tag.rb'

class Document

  def initialize(&proc)
    @stack_tags = []
    instance_eval &proc
    # @tag_final = instance_exec &proc # Funciona igual
  end

  def xml
    @root_tag.xml
  end

  private def method_missing(name, *args, &proc)
    tag = Tag.with_label(name)

    if @root_tag.nil?
      @root_tag = tag
    end

    tag.with_attributes(args.empty? ? [] : args.first)

    @stack_tags.push(tag)
    contenido = instance_eval(&proc) # wtf se pueden pasar bloques por parámetro??

    # El proc también puede devolver un Tag o un Array, pero:
    # Para el punto 2: solo queremos evaluarlo
    # Para el punto 1: solo queremos guardar el contenido si es final (normal)
    if contenido.normal?
      tag.with_child(contenido)
    end

    @stack_tags.pop

    unless @stack_tags.empty?
      @stack_tags[-1].with_child(tag)
    end

    tag
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

=begin
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
=end



