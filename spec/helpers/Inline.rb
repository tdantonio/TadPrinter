class TestAlumnoInline

  ✨Inline✨ {|campo| campo.upcase }
  attr_reader :nombre, :legajo
  def initialize(nombre, legajo, telefono, estado)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
  end

  ✨Inline✨ {|estado| estado.es_regular }
  def estado
    @estado
  end
end

class TestEstadoInline
  attr_reader :finales_rendidos, :materias_aprobadas, :es_regular
  def initialize(finales_rendidos, materias_aprobadas, es_regular)
    @finales_rendidos = finales_rendidos
    @es_regular = es_regular
    @materias_aprobadas = materias_aprobadas
  end
end