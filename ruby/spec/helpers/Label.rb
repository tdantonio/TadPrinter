✨Label✨("estudiante")
class TestAlumnoLabel
  attr_reader :nombre, :legajo, :estado

  ✨Label✨("celular")
  attr_reader :telefono

  def initialize(nombre, legajo, telefono, estado)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
  end

=begin
  ✨Label✨("celular")
  def telefono
    @telefono
  end
=end
end

✨Label✨("situacion")
class TestEstadoLabel
  attr_reader :finales_rendidos, :materias_aprobadas, :es_regular
  def initialize(finales_rendidos, materias_aprobadas, es_regular)
    @finales_rendidos = finales_rendidos
    @es_regular = es_regular
    @materias_aprobadas = materias_aprobadas
  end
end