class Annotator # Tiene que definirse antes de agregarle el hook inherited a Class
  @method_annotations = []
  @class_annotations = []

  def self.add_method_annotation(annotation)
    @method_annotations << annotation
  end

  def self.add_class_annotation(annotation)
    @class_annotations << annotation
  end

  def self.evaluate_class_annotations(clase)
    @class_annotations.each do |annotation|
      annotation.evaluate(clase, nil)
    end
    @class_annotations = []
  end

  def self.evaluate_method_annotations(clase, method_name)
    @method_annotations.each do |annotation|
      annotation.evaluate(clase, method_name)
    end
    @method_annotations = []
  end

  def self.has_method_annotations?
    not @method_annotations.empty?
  end
end

class Class
  attr_reader :getters

  def inherited(subclass)# Object recibe el mensaje :inherited cada vez que se crea una nueva clase
    Annotator.evaluate_class_annotations(subclass)
  end

  def method_added(method_name)# Cada clase particular recibe el mensaje :method_added cada vez que se le agrega un método
    if Annotator.has_method_annotations?
      @getters ||= {} # TODO: sacar si se logra solucionar el initialize
      @getters[method_name] = method_name
    end

    Annotator.evaluate_method_annotations(self, method_name)
  end

  alias old_attr_reader attr_reader
  def attr_reader (*symbols)
    old_attr_reader(*symbols)
    @getters ||= {}
    symbols.each do |symbol|
      @getters[symbol] = symbol.to_s
    end
  end

  alias old_attr_accessor attr_accessor
  def attr_accessor (*symbols)
    old_attr_accessor(*symbols)
    @getters ||= {}
    symbols.each do |symbol|
      @getters[symbol] = symbol.to_s
    end
  end
end