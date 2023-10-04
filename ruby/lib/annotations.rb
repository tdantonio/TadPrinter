# Defino variable global para main
$main = self

module Annotation
  def self.included(subclass)
    $main.define_singleton_method("✨#{subclass.name}✨") do |*args, &proc|
      Annotator.add_pending_annotation(subclass.new(*args, &proc))
    end
  end
end

class Label
  include Annotation
  def initialize(label)
    @label = label
  end

  def evaluate(clase)
    label = @label
    clase.define_method(:label) { label }
  end
end

class Ignore
  include Annotation
  def evaluate(clase)
    clase.define_method(:ignore?) { true }
  end
end

class Inline
  include Annotation
  def initialize(&proc_converter)
    @proc_converter = proc_converter
  end

  def evaluate(campo)
    # TODO
  end
end

class Custom
  include Annotation
  def initialize(&proc_serializer)
    @proc_serializer = proc_serializer
  end

  def evaluate(clase)
    proc_serializer = @proc_serializer

    clase.define_method(:primitive_attributes_as_hash) do
      {}
    end

    clase.define_method(:tag_children) do
      ContextEvaluator.new.instance_exec(self, &proc_serializer)
    end
  end
end