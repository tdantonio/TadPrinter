class Serializer
  attr_accessor :label
  def initialize(label)
    @label = label
  end

  def get_value_for(instance, getter)
    instance.send(getter)
  end

  def attribute_for?(instance, getter)
    get_value_for(instance, getter).primitive?
  end

  def child_for?(instance, getter)
    not attribute_for?(instance, getter) and not get_value_for(instance, getter).ignore?
  end
end