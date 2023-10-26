class TestAlumnoInlineError
  ✨Inline✨ {|_object| EstadoTestInlineError.new("Dormido")}
  def estado
    "dormido"
  end
end

class EstadoTestInlineError
  def initialize(nombre)
    @nombre = nombre
  end
end

