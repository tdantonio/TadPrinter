# frozen_string_literal: true

class Label
  def initialize(label)
    @label = label
  end

  def evaluate(clase)
    label = @label # TODO: Hardcodeado nashe (no me deja ponerlo adentro del bloque)
    clase.define_method(:label) { label }
  end
end

class Ignore
  def evaluate(clase)
    clase.define_method(:ignore?) { true }
  end
end

class Inline
  def initialize(&proc_converter)
    @proc_converter = proc_converter
  end

  def evaluate(campo)
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