require_relative 'tag'
require_relative 'serializer'
require_relative 'annotator'
require_relative 'annotations'
require_relative 'document'
require_relative 'contextEvaluator'


######################
# Espacio de pruebas #
######################

=begin
✨Label✨("cadena de caracteres")
class String
end

class Estado
  attr_reader :materias_aprobadas

  def initialize(materias_aprobadas)
    @materias_aprobadas = materias_aprobadas
  end
end

class A
  attr_reader :nombre

  ✨Custom✨ do |estado|
    falop { 1 }

  end
  def estado
    @estado
  end

  def initialize(nombre)
    @nombre = nombre
    @estado = Estado.new(2)
  end
end

puts Document.serialize(A.new("Matías")).xml
=end

puts ContextEvaluator.respond_to_missing?
