class Class
  @@pending_annotations = []
  @annotations = []

  attr_writer :annotations
  attr_reader :annotations

  def add_pending_annotation(annotation)
    @@pending_annotations.push(annotation)
  end

  def annotations
    @annotations
  end

  def inherited(subclass)
    unless @@pending_annotations.empty?
      subclass.annotations = @@pending_annotations
      @@pending_annotations = []
    end
  end
end

class Label
  def initialize
    Class.add_pending_annotation(self)
  end
end

def method_missing(annotation_name, *args)
  # if '✨' == annotation_name[0] and ✨ == annotation_name[-1]
  if annotation_name.match? "✨.*✨"
    Object.const_get(annotation_name.to_s.gsub('✨','')).new(*args)
  else
    super(annotation_name, *args)
  end
end

✨Label✨
class Alumno

  attr_reader :nombre, :legajo, :telefono

  attr_reader :estado

  def initialize(nombre, legajo, telefono, estado)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
  end

end

puts Alumno.annotations