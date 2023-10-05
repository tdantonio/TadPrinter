class Annotator # Tiene que definirse antes de agregarle el hook inherited a Class
  @pending_annotations = []
  def self.add_pending_annotation(annotation)
    @pending_annotations << annotation
  end

  def self.add_pending_annotations_to(clase, method_name = nil)
    @pending_annotations.each do |annotation|
      annotation.evaluate(clase, method_name)
    end
    # clase.pending_annotations = @pending_annotations
    @pending_annotations = []
  end
end

class Class
  # attr_accessor :pending_annotations
  def inherited(subclass)
    Annotator.add_pending_annotations_to(subclass)
  end

  def tag_instance(instance)
    instance.to_tag
  end

  def method_added(method_name)
    # Idea para el tema de la lista de atributos y no tener que calcularla:
    # attribute_value = send(method_name)
    #@attributes[method_name] = attribute_value if attribute_value.primitive?
    Annotator.add_pending_annotations_to(self, method_name)
  end
end

