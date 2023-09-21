require './ruby/lib/tag.rb'

class Document

  def initialize
    @stack_tags = []
    @root_tag = nil
  end


  def xml
    @root_tag.xml
  end

  def serialize(name, attributes, children, &block)

    tag = Tag.with_label(name)

    if @root_tag.nil?
      @root_tag = tag
    end


    with_attributes(tag, attributes.empty? ? [] : attributes.first)

    @stack_tags.push(tag)

    evaluate(tag, children, &block)

    @stack_tags.pop(1)

    unless @stack_tags.empty?
      @stack_tags[-1].with_child(tag)
    end

  end

  def evaluate(tag, children, &block)
    0   #hay que overridearlo en las clases hijo tipo template method
  end



  def with_attributes(tag, parametros)
    parametros.each do |clave, valor|
      tag.with_attribute(clave, valor)
    end
  end
end

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





=begin
Output:
XML:
<alumno nombre="Matias" legajo= "123456-7">
  <telefono>1234567890</telefono>
  <estado es_regular=true>
     <finales_rendidos>3</finales_rendidos>
     <materias_aprobadas>5<materias_aprobadas>
  </estado>
</alumno>

Orden de ejecucion:
documento = Document.new
documento.tag =

Tag.with_label('alumno').
  with_attribute('nombre', 'Matias').
  with_attribute('legajo', '123456-7').
  with_child(
    Tag.
      with_label('telefono').
      with_child('1234567890')).
      with_child(
          Tag.
            with_label('estado').
            with_attribute('es_regular', true).
            with_child(
              Tag.
                with_label('finales_rendidos').
                with_child('3')).
                with_child(
                  Tag.
                    with_label('materias_aprobadas').with_child('5')))
puts documento.xml
=end