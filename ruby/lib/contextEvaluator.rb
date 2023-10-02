

class ContextEvaluator
  def initialize
    @tags = []
  end

  ###########
  # Punto 1 #
  ###########
  def tag_proc(proc) # Solo sirve de pasamano para que :root_tag pueda recibirlo como un objeto también.
    instance_eval(&proc)
  end
  private def method_missing(name, *args, &proc)
    attributes = args.empty? ? {} : args.first
    children_tags = block_given? ? ContextEvaluator.new.tag_proc(proc) : []
    tag_with_children(name, attributes, children_tags)
  end

  def tag_with_children(label, attributes, possible_children_tags)
    children_tags = [possible_children_tags].flatten # [1,2,[3,4,[5]]] -> [1,2,3,4,5]
    @tags << Tag.with_everything(label, attributes, children_tags)
    # Si tiene más de un hijo, para los primeros se ignora el retorno, pero los va guardando en la lista.
    # Solo devuelve la lista de tags cuando está completa, es decir, para el último hijo.
  end

  ###########
  # Punto 2 #
  ###########
  def tag_object(object) # Al principio lo había llamado solo :tag, pero entonces no tenía un buen nombre para :tag_proc (que antes era :evaluate).
=begin
    object = object.class.pending_annotations.reduce(object) {|object, annotation| annotation.evaluate(object)}

    children_tags = tag_all(object.children)
    tag_with_children(object.label, object.primitive_attributes_as_hash, children_tags)
=end
    @tags << object.class.tag_instance(object)
  end
end


class Object
  def to_tag
    children_tags = tag_children
    Tag.with_everything(label, primitive_attributes_as_hash, children_tags)
  end

  def tag_children
    children.map do |child|
      # ContextEvaluator.new.tag_object(child) # TODO: fijarse cuál cumple mejor el requerimiento
      child.primitive? ? child : ContextEvaluator.new.tag_object(child)
    end.flatten # TODO: me hace ruido que tengamos que hacer dos veces flatten
  end

  def children
    getters # TODO: ídem :primitive_attributes_as_hash
      .map{ |getter| send(getter) }
      .select{ |attr| not attr.primitive? and not attr.ignore? }
      .flatten #[1,2,[3,4]] -> [1,2,3,4]
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

  def ignore? # TODO: No me gusta para nada
    false
  end

  def label
    self.class.to_s.downcase
  end

  def primitive_attributes_as_hash # TODO: en vez de calcularlo, hacer que se vayan guardando a medida que se definen
    atributos = Hash.new

    getters
      .select { |getter| primitive_attribute?(getter) }
      .each { |msj| atributos[msj] = send(msj) }

    atributos
  end
end