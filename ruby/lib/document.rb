require_relative 'tag.rb'

class Document

  def initialize(&proc)
    @stack_tags = []
    instance_eval(&proc)
    # @tag_final = instance_exec &proc # Funciona igual
  end

  def xml
    @tag_final.xml
  end

  private def method_missing(name, *args, &proc)
    tag = Tag.with_label(name)
    if @tag_final.nil?
      @tag_final = tag
    end
    tag.with_attributes(args.empty? ? [] : args.first)

    @stack_tags.push(tag)
    contenido = instance_eval(&proc)

    unless contenido.is_a? Tag or contenido.is_a? Array
      tag.with_child(contenido)
    end
    @stack_tags.pop

    unless @stack_tags.empty?
      @stack_tags[-1].with_child(tag)
    end

    tag
  end

  def self.serialize(object)
    Document.new(&Document.proc_automatico([object]))
  end

  def self.proc_automatico(objects)
    proc do
        objects.each { |object|

          send(object.class.to_s.downcase, object.normal_attributes_as_hash, &Document.proc_automatico(object.children))
        }
    end
  end
end


class Object
  def normal_attributes_as_hash
    atributos = Hash.new

    getters
      .select { |getter| normal?(getter) }
      .each { |msj| atributos[msj] = send(msj) }

    atributos
  end

  def getters
    instance_variables
      .map{ |atributo| atributo.to_s.delete_prefix('@') }
      .select{ |msj| respond_to? msj }
  end

  def normal?(getter)
    [String, FalseClass, TrueClass, NilClass, Numeric].include?(send(getter).class)
  end

  def children
    getters
      .select{|getter| !normal?(getter)}
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

unEstado = Estado.new(3, 5, true)
unAlumno = Alumno.new("Matias","123456-8", "1234567890", unEstado)
documento = Document.serialize(unAlumno)
puts documento.xml

###########
# Punto 1 #
###########
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




