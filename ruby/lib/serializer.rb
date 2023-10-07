class Serializer
  attr_accessor :ignore

  def initialize(object, getter)
    @object = object
    @getter = getter
    @ignore = false
  end

  def label
    if not attribute? and actual_value.class.class_annotations.any? { |annotation| annotation.is_a? Label }
      actual_value.label
    else
      @getter.to_s
    end
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
    not get_value.primitive? and not @ignore and not actual_value.ignore?
  end

  def attribute?
    get_value.primitive? and not @ignore # and not actual_value.ignore?
  end

end