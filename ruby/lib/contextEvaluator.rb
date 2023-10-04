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
end


class Object
  def to_tag(label = self.label)
    children_tags = tag_children
    Tag.with_everything(label, primitive_attributes_as_hash, children_tags)
  end

  def tag_children
    non_primitive_attributes_as_hash.map do |label, child|
      child.to_tag(label) # TODO: fijarse cuál cumple mejor el requerimiento
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

=begin
class Class
  def method_added(method_name)
    0
  end
end
=end
