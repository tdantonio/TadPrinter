require_relative 'tag.rb'

class Document

  def initialize(&proc)
    if block_given?
      @root_tag = TagCreatorBlocks.new((Proc.new &proc), first_one = true).tag
    end
    # @tag_final = instance_exec &proc # Funciona igual
  end

  def xml
    @root_tag.xml
  end


  def serialize(object)
    @root_tag = TagCreatorObjects.new(object).tag
  end

  def self.automatic_proc(objects)
    proc do
        objects.each { |object|
          send(object.class.to_s.downcase, object.normal_attributes_as_hash, &Document.automatic_proc(object.children)) # TODO: testear si es lo mismo pasarlo como bloque
        }
    end
  end
end



module TagCreator

  attr_reader :tag


  def initialize(input)
    @contenido = evaluate(input)
  end






end

class TagCreatorBlocks
  include TagCreator
  attr_reader :tags

  def initialize(input, first_one = false)
    @tags = []
    super(input)
    if @contenido.is_normal?
      @tags << @contenido
    end
    if first_one
      @tag = @tags.first
    end
  end


  private def method_missing(name, *args, &block)

    new_tag = Tag.with_label(name)
    new_tag.with_attributes(args.empty? ? [] : args.first)

    if block_given?
      new_tag.with_children(TagCreatorBlocks.new((Proc.new &block)).tags)
    end

    @tags << new_tag

  end

  def evaluate(input)
    instance_eval &input
  end



end

=begin
El nombre del tag raíz debe ser el nombre de la clase de X, en minúsculas.
  Los atributos de X que no tengan definido un getter se ignoran.
    Los atributos de X con getter que referencian a Strings, Booleanos, Números o nil se deben serializar como atributos del tag raíz.
  Los atributos de X con getter que referencian a Arrays de objetos de cualquier tipo deben serializarse cómo tags hijos, conteniendo un nuevo tag hijo por cada elemento del array. Estos tags deben llamarse como la clase de los valores que representan.
  Los atributos de X con getter que referencian a cualquier otro tipo de objeto se deben serializar cómo tags hijos del tag raíz, cada uno con el nombre del atributo en cuestión.
=end


class TagCreatorObjects
  include TagCreator

  def initialize(input)
    @tag = Tag.with_label(input.class.to_s.downcase)
    super(input)
  end

  def evaluate(object)
    @instance_attributes = object.instance_variables_with_getters
    @instance_attributes.each do |name, value|
      factory_attributes(name, value).adopt_itself(@tag)

    end

  end

  def factory_attributes(name, value)
    if value.is_a? Array
      ArrayAttribute.new(name, value)
    elsif value.is_normal?
      AttributeWithGetter.new(name, value)
    else
      ObjectAttribute.new(name, value)
    end
  end




end

module Attribute
  def initialize(name, value)
    @name = name
    @value = value
  end

end

class AttributeWithGetter

  include Attribute

  def adopt_itself(parent)
    parent.with_attribute(@name, @value)
  end

end

class ArrayAttribute

  include Attribute

  def initialize(name, value)
    super(name, value)
    @tag = Tag.with_label(name)
  end

  def add_children
    @value.each do |child|
      if child.class.is_normal?
        new_tag = Tag.with_label(child.class.to_s.downcase)
        new_tag.with_child(child)
      else
        new_tag = TagCreatorObjects.new(child).tag

    end
      @tag.with_child(new_tag)
    end
  end

  def adopt_itself(parent)
    add_children
    parent.with_child(@tag)
  end



end


class ObjectAttribute

  include Attribute

  def adopt_itself(parent)
    parent.with_child(TagCreatorObjects.new(@value).tag)
  end

end

class Object
  def normal_attributes_as_hash
    atributos = Hash.new

    getters
      .select { |getter| normal_attribute?(getter) }
      .each { |msj| atributos[msj] = send(msj) }

    atributos
  end

  def getters
    instance_variables
      .map{ |atributo| atributo.to_s.delete_prefix('@') }
      .select{ |msj| respond_to? msj }
  end

  def instance_variables_with_getters
    result = {}
    self.class.instance_methods(false).each do |method_name|
      if method_name.to_s.end_with?("=")
        # Skip setter methods
        next
      end

      getter_method = method_name
      if respond_to?(getter_method) && instance_variable_defined?("@#{getter_method}")
        # Check if there's a corresponding getter method and instance variable
        value = instance_variable_get("@#{getter_method}")
        result[getter_method] = value
      end
    end
    result
  end

  def normal_attribute?(getter)
    send(getter).is_normal?
  end

  def is_normal?
    normal_classes = [String, FalseClass, TrueClass, NilClass, Numeric]
    normal_classes.any?{ |normal_class| is_a? normal_class }
  end

  def children
    getters
      .select{|getter| !normal_attribute?(getter) }
      .flatten #[1,2,[3,4]] -> [1,2,3,4]
      .map{|getter| send(getter)}
  end
end



class Alumno
  attr_reader :nombre, :legajo, :estado
  def initialize(nombre, legajo, telefono, estado)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
  end
end


class Estado
  attr_reader :finales_rendidos, :materias_aprobadas, :es_regular
  def initialize(finales_rendidos, materias_aprobadas, es_regular)
    @finales_rendidos = finales_rendidos
    @es_regular = es_regular
    @materias_aprobadas = materias_aprobadas
  end
end

estado = Estado.new(3, 5, true)
alumno = Alumno.new("Matias","123456-8", "1234567890", estado)
documento = Document.new
documento.serialize(alumno)
puts documento.xml

=begin
documento = Document.new do
  alumno nombre: "Matias", legajo: "123456-7" do
    telefono { "1234567890" }
    estado es_regular: true do
      finales_rendidos { 3 }
      materias_aprobadas { 5 }
    end
  end
end

puts documento.xml

=end


