=begin
✨Inline✨ {|object| 2}
class TestInlineError

end
=end


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