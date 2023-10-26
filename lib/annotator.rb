class Annotator # Tiene que definirse antes de agregarle el hook inherited a Class
  @method_annotations = []
  @class_annotations = []

  def self.add_method_annotation(annotation)
    @method_annotations << annotation
  end

  def self.add_class_annotation(annotation)
    @class_annotations << annotation
  end

  def self.evaluate_class_annotations(clase)
    @class_annotations.each do |annotation|
      annotation.evaluate_class(clase)
    end
    clase.class_annotations = @class_annotations.clone
    @class_annotations = []
  end

  def self.pop_method_annotations
    method_annotations = @method_annotations
    @method_annotations = []
    method_annotations
  end

  def self.empty_method_annotations
    @method_annotations = []
  end
end

class Class
  attr_writer :class_annotations

  def add_method_annotations(method_name, annotations) # Solo sirve para poder usar @method_annotations sin cambiar de contexto dentro del bloque
    method_annotations[method_name] = annotations
  end

  def class_annotations
    @class_annotations ||= {}
  end

  def method_annotations
    @method_annotations ||= {}
  end

  def method_added(method_name)
    add_method_annotations(method_name, Annotator.pop_method_annotations)
    # Guarda todos los métodos, inclusive los que no tienen annotations (con [])
  end

  private def attr_redefinition(old_method_symbol, *new_methods)
    pending = Annotator.pop_method_annotations
    send(old_method_symbol, *new_methods)
    new_methods.each do |method|
      add_method_annotations(method, pending)
    end
  end

  alias old_attr_reader attr_reader
  def attr_reader (*symbols)
    attr_redefinition(:old_attr_reader, *symbols)
  end

  alias old_attr_accessor attr_accessor
  def attr_accessor (*symbols)
    attr_redefinition(:old_attr_accessor, *symbols)
  end
end


# Esto se usa como reemplazo del :inherited en Class, ya que es más simple y además nos permite agregar
# annotations a clases que ya estaban definidas, como, por ejemplo, hicimos con Custom en Array.
class_trace = TracePoint.new(:class) do |tp|
  # TODO: extender nuestra solución a Module en vez de a Class
  if tp.self.is_a? Class # Si no se pregunta esto, también aplica para modules
    Annotator.evaluate_class_annotations(tp.self)
  end
end
class_trace.enable


=begin
Esto es para que, si se hace una clase vacía (sin métodos) o se extiende una clase ya existente,
al usar annotations de métodos (por más que no se defina ninguno), estas no perduren para la próxima
clase a definir. Por ejemplo:

class A
  ✨ignore✨
end

class B
  def energia
    100
  end
end

Es un caso muy sutil e improbable, pero bueno, no molesta mucho contemplarlo.
=end
class_empty_trace = TracePoint.new(:end) do |tp|
  Annotator.empty_method_annotations
end
class_empty_trace.enable

