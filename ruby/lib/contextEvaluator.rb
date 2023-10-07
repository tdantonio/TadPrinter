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
    serializers = getters.map do |getter, annotations|
      Serializer.new(self, getter).evaluate(annotations)
    end

    Tag.with_everything(label, attributes_as_hash(serializers), tag_children(serializers))
  end

  def tag_children(serializers)
    serializers
      .select { |serializer| serializer.child? }
      .map do |serializer|
        serializer.get_value.to_tag(serializer.label) # TODO: fijarse cuál cumple mejor el requerimiento (corregir para que quede igual que lo q dijo agus en ds)
        # child.primitive? ? child : ContextEvaluator.new.tag_object(child).first
    end
    # .flatten # Para cumplir lo del enunciado
  end

  def getters
    self.class.method_annotations.select do |method, _annotations|
      instance_variables
        .map {|instance_variable| instance_variable.to_s.delete_prefix('@')}
        .include?(method.to_s)
    end
  end

  def primitive_attribute?(getter)
    send(getter).primitive?
  end

  def primitive?
    primitive_classes = [String, FalseClass, TrueClass, NilClass, Numeric]
    primitive_classes.any?{ |primitive_class| is_a? primitive_class }
  end

  def attributes_as_hash(serializers)
    attributes = Hash.new

    serializers
      .select { |serializer| serializer.attribute? }
      .each { |serializer| attributes[serializer.label] = serializer.get_value }

    attributes
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

class Array
  def to_tag(label)
    Tag.with_everything(label, {} , tag_children)
  end

  def tag_children
    map do |child|
      if child.primitive?
        Tag.with_everything(child.label, {}, [child])
      else
        child.to_tag
      end
    end
  end

  # Para cumplir lo del enunciado
=begin
  def to_tag
    map do |child|
      if child.primitive?
        Tag.with_everything(child.label, {}, [child])
      else
        child.to_tag
      end
    end
=end
end