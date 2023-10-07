class Annotation
  def self.annotation_name(subclass)
    "✨#{subclass.name}✨"
  end

  def self.annotation_method(subclass, add_method_name)
    proc do |*args, &proc|
      Annotator.send(add_method_name, subclass.new(*args, &proc))
    end
  end
end


# Defino variable global para main, para usarla en cualquier contexto
$main = self

module ClassAnnotation
  # include Annotation
  def self.included(subclass)
    annotation_name = Annotation.annotation_name(subclass)
    annotation_method = Annotation.annotation_method(subclass, :add_class_annotation)
    $main.define_singleton_method(annotation_name, &annotation_method)
  end
end

module MethodAnnotation

  def self.included(subclass)
    annotation_name = Annotation.annotation_name(subclass)
    annotation_method = Annotation.annotation_method(subclass, :add_method_annotation)
    Class.define_method(annotation_name, &annotation_method)
  end
end

class Label
  include ClassAnnotation
  include MethodAnnotation
  def initialize(label)
    @label = label
  end

  def evaluate_class(clase)
    label = @label
    clase.define_method(:label) { label }
  end

  def evaluate_method(serializer)
    label = @label
    serializer.define_singleton_method(:label) { label }
  end
end

class Ignore
  include ClassAnnotation
  include MethodAnnotation

  def evaluate_class(clase)
      clase.define_method(:ignore?) { true }
  end

  def evaluate_method(serializer)
    serializer.ignore = true
  end
end

class Inline
  include MethodAnnotation

  def initialize(&proc_converter)
    @proc_converter = proc_converter
  end

  def evaluate_method(serializer)
    proc_converter = @proc_converter
    serializer.define_singleton_method(:get_value) do
      instance_exec(serializer.actual_value, &proc_converter)
    end
  end
end

class Custom
  include ClassAnnotation
  def initialize(&proc_serializer)
    @proc_serializer = proc_serializer
  end

  def evaluate_class(clase)
    proc_serializer = @proc_serializer

    clase.define_method(:tag_children) do |_serializers|
      ContextEvaluator.new.instance_exec(self, &proc_serializer)
    end

    clase.define_method(:attributes_as_hash) do |_serializers|
      {}
    end
  end
end