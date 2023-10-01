class Annotation
  def initialize
    Annotator.add_pending_annotation(self)
  end

  def included

  end
end

class Label < Annotation
  def initialize(label)
    @label = label
    super() # Hay que poner paréntesis porque, sino, le pasa implícitamente los parámetros q recibe (en este caso, label)
  end

  def evaluate(clase)
    label = @label # TODO: Hardcodeado nashe (no me deja ponerlo adentro del bloque)
    clase.define_method(:label) { label }
  end
end

class Ignore < Annotation
  def evaluate(clase)
    clase.define_method(:ignore?) { true }
  end
end

class Inline < Annotation
  def initialize(&proc_converter)
    @proc_converter = proc_converter
    super()
  end

  def evaluate(campo)
    # TODO
  end
end

class Custom < Annotation
  def initialize(&proc_serializer)
    @proc_serializer = proc_serializer
    super()
  end

  def evaluate(clase)
    # TODO
  end
end