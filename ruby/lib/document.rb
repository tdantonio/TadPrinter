require_relative 'tag.rb'

class Document
  def initialize(&proc)
    @root_tag = ContextEvaluator.new.instance_eval(&proc).first
  end

  def xml
    @root_tag.xml
  end
end

class ContextEvaluator
  def initialize
    @tags = []
  end

  private def method_missing(name, *args, &proc)
    tag_children(name, args.empty? ? {} : args.first, ContextEvaluator.new.instance_eval(&proc))
  end

  def tag_children(label, attributes, possible_children)
    children = [possible_children].flatten

    @tags << Tag.with_all(label, attributes, children)
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
