# frozen_string_literal: true

class Label
  def initialize(label)
    @label = label
    Annotator.add_pending_annotation(self)
  end

  def evaluate(clase)
    label = @label # TODO: Hardcodeado nashe (no me deja ponerlo adentro del bloque)
    clase.define_method(:label) { label }
  end
end

class Ignore
  def initialize
    Annotator.add_pending_annotation(self) # TODO: eliminar repetición de lógica
  end
  def evaluate(clase)
    clase.define_method(:ignore?) { true }
  end
end

class Inline
  def initialize(&proc_converter)
    @proc_converter = proc_converter
  end

  def evaluate(clase)
    # TODO
  end
end

class Custom
  def initialize(&proc_serializer)
    @proc_serializer = proc_serializer
  end

  def evaluate(clase)
    # TODO
  end
end