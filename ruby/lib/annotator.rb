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

def method_missing(annotation_name, *args)
  if annotation_name.match? "✨.*✨"
    annotation_class = Object.const_get(annotation_name.to_s.gsub('✨',''))
    # TODO: falta lanzar un error más descriptivo en caso de que no matchee con ninguna clase existente
    Annotator.add_pending_annotation(annotation_class.new(*args))
  else
    super(annotation_name, *args) # warning: redefining Object#method_missing may cause infinite loop
  end
end