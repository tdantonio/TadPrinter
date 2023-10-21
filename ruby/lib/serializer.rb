class Serializer

  def initialize(object, getter)
    @object = object
    @getter = getter
  end

  def label
    if actual_value.class.class_annotations.any? { |annotation| annotation.is_a? Label }
      actual_value.label
    else
      @getter.to_s
    end
  end

  def ignore
    false
  end

  def actual_value
    @object.send(@getter)
  end

  def get_value
    actual_value
  end

  def evaluate(annotations)
    annotations.each do |annotation|
      annotation.evaluate_method(self)
    end
    self
  end

  def child?
    ! get_value.primitive? && ! ignore && ! actual_value.ignore?
  end

  def attribute?
    get_value.primitive? && ! ignore && ! actual_value.ignore?
  end

  # Esto es para no permitir que se defina un Inline que convierta al retorno de método en un child.
  def validate_attribute_return(proc_converter)
    unless instance_exec(actual_value, &proc_converter).primitive?
      raise AnnotationError, "Inline modification can not be representable as an attribute"
    end
  end
end

class AnnotationError < ArgumentError
end

