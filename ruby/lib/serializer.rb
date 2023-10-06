class Serializer
  attr_accessor :label, :ignore
  def initialize(label)
    @label = label
    @ignore = false
  end

  def get_value_for(instance, getter)
    instance.send(getter)
  end

  # TODO: eliminar repetición de lógica
  def attribute_for?(instance, getter)
    get_value_for(instance, getter).primitive? and not @ignore
  end

  def child_for?(instance, getter)
    not get_value_for(instance, getter).primitive? and not @ignore and not get_value_for(instance, getter).ignore?
  end

  # Idea para eliminarla
=begin
  def attribute_for?(instance, getter)
    x(instance, getter, true)
  end

  def child_for?(instance, getter)
    x(instance, getter, false)
  end

  def x(instance, getter, negar)
    negar == get_value_for(instance, getter).primitive? and not @ignore and not get_value_for(instance, getter).ignore?
  end
=end
end