class ContextEvaluator
  def initialize
    @tags = []
  end

  ###########
  # Punto 1 #
  ###########
  private def method_missing(name, **attributes, &proc)
    children_tags = block_given? ? ContextEvaluator.new.instance_eval(&proc) : []
    tag_with_children(name, attributes, children_tags)
  end

  def tag_with_children(label, attributes, possible_children_tags)
    children_tags = possible_children_tags
    unless possible_children_tags.is_a? Array
      children_tags = [possible_children_tags]
    end
    # O sino:
    # children_tags = [possible_children_tags].flatten # [1,2,[3,4,[5]]] -> [1,2,3,4,5]

    @tags << Tag.with_everything(label, attributes, children_tags)
    # Si tiene más de un hijo, para los primeros se ignora el retorno, pero los va guardando en la lista.
    # Solo devuelve la lista de tags cuando está completa, es decir, para el último hijo.
  end
end

class Object
  def to_tag(label = self.label)
    Tag.with_everything(label, attributes_as_hash, tag_children)
  end

  private def tag_children
    serializers
      .select { |serializer| serializer.child? }
      .map do |serializer|
        serializer.get_value.to_tag(serializer.label)
    end
  end

  private def serializers
    getters.map do |getter, annotations|
      Serializer.new(self, getter).evaluate(annotations)
    end
  end

  private def getters # TODO: el nombre no está tan bueno
    self.class.method_annotations.select do |method, annotations|
      getter?(method) || ! annotations.empty?
    end
  end

  def getter?(method)
    instance_variables
      .map {|instance_variable| instance_variable.to_s.delete_prefix('@')}
      .include?(method.to_s)
  end

  def primitive?
    is_a? Primitive
  end

  private def attributes_as_hash
    attributes = Hash.new

    serializers
      .select { |serializer| serializer.attribute? }
      .each { |serializer| attributes[serializer.label] = serializer.get_value }
    attributes
  end

  def label
    self.class.to_s.downcase
  end

  def ignore?
    false
  end
end


✨Custom✨ do |array|
  array.map do |child|
    if child.primitive?
      Tag.with_label(child.label).with_child(child)
    else
      child.to_tag
    end
  end
end
class Array
end

module Primitive
end

[String, TrueClass, FalseClass, Numeric, NilClass].each{|primitiveClass| primitiveClass.include Primitive}