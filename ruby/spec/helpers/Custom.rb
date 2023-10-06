class TestAlumnoCustom

  attr_reader :nombre, :legajo, :telefono

  attr_reader :estadocustom

  def initialize(nombre, legajo, telefono, estado)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estadocustom = estado
  end

end

✨Custom✨ do |estado|
  regular { estado.es_regular }
  pendientes { estado.materias_aprobadas - estado.finales_rendidos }
end
class TestEstadoCustom
  attr_reader :finales_rendidos, :materias_aprobadas, :es_regular
  def initialize(finales_rendidos, materias_aprobadas, es_regular)
    @finales_rendidos = finales_rendidos
    @es_regular = es_regular
    @materias_aprobadas = materias_aprobadas
  end
end
