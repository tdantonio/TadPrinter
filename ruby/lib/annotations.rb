# Defino variable global para main
$main = self

class Annotation # TODO: no me gusta que hereden solo para saber si Annotation fue heredado
  def self.inherited(subclass)
    $main.define_singleton_method(subclass.annotation_name) do |*args, &proc|
      Annotator.add_pending_annotation(subclass.new(*args, &proc))
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
    proc_serializer = @proc_serializer
    clase.define_singleton_method(:tag_instance) do |instance|
      children_tags = ContextEvaluator.new.instance_exec(instance, &proc_serializer)
      Tag.with_everything(instance.label, {}, children_tags)
    end
  end
end