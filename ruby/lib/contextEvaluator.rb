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
    Tag.with_everything(label, primitive_attributes_as_hash, children_tags)
  end

  def tag_children
    non_primitive_attributes_as_hash.map do |label, child|
      child.to_tag(label) # TODO: fijarse cuál cumple mejor el requerimiento (corregir para que quede igual que lo q dijo agus en ds)
      # child.primitive? ? child : ContextEvaluator.new.tag_object(child).first
    end
  end

  def non_primitive_attributes_as_hash # TODO: en vez de calcularlo, hacer que se vayan guardando a medida que se definen
    atributos = Hash.new

    getters
      .select { |getter| not primitive_attribute?(getter) and not send(getter).ignore? }
      .each do |getter|
        attr = send(getter)
        if attr.is_a? Array
          attr.each { |attr|
            atributos[attr.label] = attr
          }
        else
          atributos[getter] = attr
      end
    end

    atributos
  end

  def getters
    instance_variables
      .map{ |atributo| atributo.to_s.delete_prefix('@') }
      .select{ |msj| respond_to? msj }
  end

  def primitive_attribute?(getter)
    send(getter).primitive?
  end

  def primitive?
    primitive_classes = [String, FalseClass, TrueClass, NilClass, Numeric]
    primitive_classes.any?{ |primitive_class| is_a? primitive_class }
  end

  def primitive_attributes_as_hash # TODO: en vez de calcularlo, hacer que se vayan guardando a medida que se definen
    atributos = Hash.new

    getters
      .select { |getter| primitive_attribute?(getter) }
      .each { |msj| atributos[msj] = send(msj) }

    atributos
  end

  ###########
  # Punto 3 #
  ###########
  #
  def ignore?
    false
  end

  def label
    self.class.to_s.downcase
  end
end