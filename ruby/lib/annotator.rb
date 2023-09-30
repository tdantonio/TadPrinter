# frozen_string_literal: true

class Annotator # Tiene que definirse antes de extender a Class
  @pending_annotations = []
  def self.add_pending_annotation(annotation)
    @pending_annotations << annotation
  end

  def self.add_pending_annotations_to(clase)
    clase.add_annotations(@pending_annotations)
    @pending_annotations = []
  end
end

class Class
  def inherited(subclass)
    Annotator.add_pending_annotations_to(subclass)
  end

  def add_annotations(annotations)
    annotations.each do |annotation|
      annotation.evaluate(self)
    end
  end
end

# Hay alta repetición de lógica igual pero bueno, todo para ahorrar usar el method_missing
class << self
  def ✨Label✨(new_label)

    Annotator.add_pending_annotation(Label.new(new_label))
  end

  def ✨Ignore✨
    Annotator.add_pending_annotation(Ignore.new)
  end

  def ✨Custom✨(&proc)
    Annotator.add_pending_annotation(Custom.new(&proc))
  end
end
=begin
Idea para evitar repetición de lógica:
- Hacer que cada annotation herede de Annotation, quien tiene un initialize que
haga el Annotator.add_pending_annotation(Ignore.new)
(Rompe porque cada Annotation tiene q inicialiarse de una forma distinta)
=end


# TODO: ¿Cuál es la diferencia con lo siguiente?
=begin
def ✨Label✨(new_label)
  Annotator.add_pending_annotation(Label.new(new_label))
end

def ✨Ignore✨
  Annotator.add_pending_annotation(Ignore.new)
end

def ✨Custom✨(&proc)
  Annotator.add_pending_annotation(Custom.new(&proc))
end
=end