class Annotator # Tiene que definirse antes de agregarle el hook inherited a Class
  @pending_annotations = []

  def self.add_pending_annotation(annotation)
    @pending_annotations << annotation
  end

  def self.add_pending_annotations_to(clase)
    @pending_annotations.each do |annotation|
      annotation.evaluate(clase)
    end
    @pending_annotations = []
  end
end

class Class
  def inherited(subclass)
    Annotator.add_pending_annotations_to(subclass)
  end

  def tag_instance(instance)
    instance.to_tag
  end
end

