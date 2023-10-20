require_relative 'tag'
require_relative 'serializer'
require_relative 'annotator'
require_relative 'annotations'
require_relative 'document'
require_relative 'contextEvaluator'


######################
# Espacio de pruebas #
######################

class A
  ✨Ignore✨
end

class B
  attr_reader :telefono

  def initialize(telefono)
    @telefono = telefono
  end
end

b = B.new("1234567890")

p Document.serialize(b).xml