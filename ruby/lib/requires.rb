require_relative 'tag'
require_relative 'serializer'
require_relative 'contextEvaluator'
require_relative 'annotator'
require_relative 'annotations'
require_relative 'document'


######################
# Espacio de pruebas #
######################
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
