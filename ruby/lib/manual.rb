# frozen_string_literal: true
require './ruby/lib/document.rb'
require './ruby/lib/tag.rb'




class Manual < Document

  def initialize(&block)
    super
    instance_eval(&block)
  end

  private def method_missing(name, *args, &proc)

    serialize(name, args, 0, &proc)

  end

  def evaluate(tag, children, &proc)

    contenido = yield

    unless contenido.is_a? Tag
      tag.with_child(contenido)
    end
  end
end


documento = Manual.new {
  alumno nombre: "Matias", legajo: "123456-7" do
    telefono { "1234567890" }
    estado es_regular: true do
      finales_rendidos { 3 }
      materias_aprobadas { 5 }
    end
  end
}

puts documento.xml
