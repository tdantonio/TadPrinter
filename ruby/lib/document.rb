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
class Alumno
  attr_reader :nombre, :telefono
  attr_reader :legajo, :estado

  def initialize(nombre, legajo, telefono, estado, dni)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
    @dni = dni
  end

  def dni
    @dni
  end
end

✨Ignore✨
class Estado
  attr_reader :finales_rendidos, :materias_aprobadas, :es_regular
  def initialize(finales_rendidos, materias_aprobadas, es_regular)
    @finales_rendidos = finales_rendidos
    @es_regular = es_regular
    @materias_aprobadas = materias_aprobadas
  end
end

unEstado = Estado.new(3, 5, true)
unAlumno = Alumno.new("Matias","123456-7", "1234567890", unEstado, "12345678")
puts Document.serialize(unAlumno).xml