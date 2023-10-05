class Annotator # Tiene que definirse antes de agregarle el hook inherited a Class
  @pending_annotations = []

  def self.add_pending_annotation(annotation)
    @pending_annotations << annotation
  end

  def self.add_pending_annotations_to(clase, method_name = nil)
    @pending_annotations.each do |annotation|
      annotation.evaluate(clase, method_name)
    end
    @pending_annotations = []
  end

  def self.has_pending_annotations?
    not @pending_annotations.empty?
  end
end

class Class
  attr_reader :getters

  def initialize
    @getters = {}
  end

  def inherited(subclass)# Object recibe el mensaje :inherited cada vez que se crea una nueva clase
    Annotator.add_pending_annotations_to(subclass)
  end

  def method_added(method_name)# Cada clase particular recibe el mensaje :method_added cada vez que se le agrega un método
    if Annotator.has_pending_annotations?
      @getters ||= {} # TODO: sacar si se logra solucionar el initialize
      @getters[method_name] = method_name
    end

    Annotator.add_pending_annotations_to(self, method_name)
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