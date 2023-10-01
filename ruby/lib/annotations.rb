# Defino variable global para main
$main = self

class Annotation
  def self.inherited(subclass)
    $main.define_singleton_method(subclass.annotation_name) do |*args|
      Annotator.add_pending_annotation(subclass.new(*args))
    end
  end

  def self.annotation_name
    "✨#{name}✨"
  end
end

class Label < Annotation
  def initialize(label)
    @label = label
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
  end

  def evaluate(campo)
    # TODO
  end
end

class Custom < Annotation
  def initialize(&proc_serializer)
    @proc_serializer = proc_serializer
  end

  def evaluate(clase)
    # TODO
  end
end