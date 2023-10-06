class Annotator # Tiene que definirse antes de agregarle el hook inherited a Class
  @method_annotations = []
  @class_annotations = []
  @pending_attr_reader = false

  def self.pending_multiple_methods(bool)
    @pending_attr_reader = bool
  end

  def self.empty_method_annotations
    @method_annotations = []
    @pending_attr_reader = false
  end

  def self.add_method_annotation(annotation)
    @method_annotations << annotation
  end

  def self.add_class_annotation(annotation)
    @class_annotations << annotation
  end

  # TODO: eliminar repetición de lógica
  def self.evaluate_class_annotations(clase)
    @class_annotations.each do |annotation|
      annotation.evaluate(clase, nil)
    end
    clase.annotations = @class_annotations.clone
    @class_annotations = []
  end

  def self.evaluate_method_annotations(clase, method_name)
    @method_annotations.each do |annotation|
      annotation.evaluate(clase, method_name)
    end
    @method_annotations = [] unless @pending_attr_reader
  end

  def self.has_method_annotations?
    not @method_annotations.empty?
  end
end

class Class
  attr_reader :getters
  attr_accessor :annotations

  def inherited(subclass)# Object recibe el mensaje :inherited cada vez que se crea una nueva clase
    Annotator.evaluate_class_annotations(subclass)
  end

  def delete_getter(key)
    getters.delete(key)
  end

  def method_added(method_name)
    # Cada clase particular recibe el mensaje :method_added cada vez que se le agrega un método
    if Annotator.has_method_annotations?
      @getters ||= {} # TODO: sacar si se logra solucionar el initialize
      @getters[method_name] = Serializer.new(method_name.to_s)
    end

    Annotator.evaluate_method_annotations(self, method_name)
  end


  # TODO: eliminar repetición de lógica
  alias old_attr_reader attr_reader
  def attr_reader (*symbols)
    @getters ||= {}
    symbols.each do |symbol|
      @getters[symbol] = Serializer.new(symbol.to_s)
    end

    Annotator.pending_multiple_methods(true)
    new_methods = old_attr_reader(*symbols)
    Annotator.empty_method_annotations
    new_methods
  end

  alias old_attr_accessor attr_accessor
  def attr_accessor (*symbols)
    @getters ||= {}
    symbols.each do |symbol|
      @getters[symbol] = Serializer.new(symbol.to_s)
    end

    Annotator.pending_multiple_methods(true)
    new_methods = old_attr_accessor(*symbols)
    Annotator.empty_method_annotations
    new_methods
  end
end