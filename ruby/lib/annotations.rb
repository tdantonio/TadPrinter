# Defino variable global para main
$main = self

module Annotation
  def self.included(subclass)
    annotation_name = "✨#{subclass.name}✨"
    annotation_method = proc do |*args, &proc|
      Annotator.add_pending_annotation(subclass.new(*args, &proc))
    end
    $main.define_singleton_method(annotation_name, &annotation_method)
    Class.define_method(annotation_name, &annotation_method)
  end
end

class Label
  include Annotation
  def initialize(label)
    @label = label
  end

  def evaluate(clase, method_name)
    label = @label
    method_name.nil? ? clase.define_method(:label) { label } : clase.send(method_name).define_singleton_method(:label) { label }
  end
end

class Ignore
  include Annotation
  def evaluate(clase, method_name)
    method_name.nil? ? clase.define_method(:ignore?) { true } : nil #TODO si los agregaramos a una lista/hash seria borrarlo de ahi y listo
  end
end

class Inline
  include Annotation
  def initialize(&proc_converter)
    @proc_converter = proc_converter
  end

  def evaluate(campo, method_name)
    # TODO
  end
end

class Custom
  include Annotation
  def initialize(&proc_serializer)
    @proc_serializer = proc_serializer
  end

  def evaluate(clase, method_name)
    proc_serializer = @proc_serializer

    clase.define_method(:primitive_attributes_as_hash) do
      {}
    end

    clase.define_method(:tag_children) do
      ContextEvaluator.new.instance_exec(self, &proc_serializer)
    end
  end
end