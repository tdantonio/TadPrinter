class ContextEvaluator
  def initialize
    @tags = []
  end

  ###########
  # Punto 1 #
  ###########
  private def method_missing(name, *args, &proc)
    attributes = args.empty? ? {} : args.first
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

  ###########
  # Punto 2 #
  ###########
  def to_tag(label = self.label)
    children_tags = tag_children
    Tag.with_everything(label, attributes_as_hash, children_tags)
  end

  def tag_children
    children_as_hash.map do |label, child|
      child.to_tag(label) # TODO: fijarse cuál cumple mejor el requerimiento (corregir para que quede igual que lo q dijo agus en ds)
      # child.primitive? ? child : ContextEvaluator.new.tag_object(child).first
    end
  end

  def children_as_hash
    children = Hash.new

    self.class.getters
      .select { |getter, serializer| serializer.child_for?(self, getter) }
      .each do |getter, serializer|
        attr_value = send(getter)
        if attr_value.is_a? Array
          attr_value.each do |array_attr|
            children[array_attr.label] = array_attr
          end
        else
          if attr_value.class.annotations.any? { | annotation| annotation.is_a? Label }
            serializer.label = attr_value.label
          end
          children[serializer.label] = attr_value
        end
      end

    children
  end

=begin
  def non_primitive_attributes_as_hash
    atributos = Hash.new

    self.class.getters
      .select { |getter, _label| not primitive_attribute?(getter) and not send(getter).ignore? } # Este es el ignore de clase
      .each do |getter, label|
        attr = send(getter)
        if attr.is_a? Array
          attr.each { |attr|
            atributos[attr.label] = attr
          }
        else
          if attr.class.annotations.any? { | annotation| annotation.is_a? Label }
            label = attr.label
          end

          atributos[label] = attr
      end
    end

    atributos
  end
=end

  def primitive?
    primitive_classes = [String, FalseClass, TrueClass, NilClass, Numeric]
    primitive_classes.any?{ |primitive_class| is_a? primitive_class }
  end

  def attributes_as_hash
    atributos = Hash.new

    self.class.getters
      .select { |getter, serializer| serializer.attribute_for?(self, getter) }
      .each { |getter, serializer| atributos[serializer.label] = serializer.get_value_for(self, getter) }

    atributos
  end

  ###########
  # Punto 3 #
  ###########
  def label
    self.class.to_s.downcase
  end

  def ignore?
    false
  end
end