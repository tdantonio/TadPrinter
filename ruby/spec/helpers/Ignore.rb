class TestAlumnoIgnore
  ✨Ignore✨
  attr_reader :nombre, :telefono

  attr_reader :legajo, :estado

  def initialize(nombre, legajo, telefono, estado, dni)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
    @dni = dni
  end

=begin
  ✨Ignore✨
  def nombre
    @nombre
  end

  ✨Ignore✨
  def telefono
    @telefono
  end
=end

  ✨Ignore✨
  def dni
    @dni
  end
end

✨Ignore✨
class TestEstadoIgnore
  attr_reader :finales_rendidos, :materias_aprobadas, :es_regular
  def initialize(finales_rendidos, materias_aprobadas, es_regular)
    @finales_rendidos = finales_rendidos
    @es_regular = es_regular
    @materias_aprobadas = materias_aprobadas
  end
end