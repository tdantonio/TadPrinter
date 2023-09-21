require './ruby/lib/tag.rb'

class Document

  def initialize(&bloque)
    @stack_tags = []
    proc = bloque || {}
    @tag_final = instance_eval(&proc)
  end

  def xml
    @tag_final.xml
  end

  def serialize(objeto)
    @tag_final = Tag.with_label(objeto.class.to_s.downcase)

    # Se obtienen los atributos del objeto y se meten en un hash
    getters = objeto.instance_variables.map{ |a| a.to_s.delete_prefix('@')}.select{|m| objeto.respond_to?m}
    atributos = Hash.new
    getters.each { |m| atributos[m] = objeto.send(m) }

    # A partir del Hash se agregar los atributos al tag
    with_attributes(@tag_final, atributos)

  end

  private def method_missing(name, *args, &proc)
    tag = Tag.with_label(name)

    with_attributes(tag, args.empty? ? [] : args.first)

    @stack_tags.push(tag)
    contenido = instance_eval(&proc)
    unless contenido.is_a? Tag
      tag.with_child(contenido)
    end
    @stack_tags.pop

    unless @stack_tags.empty?
      @stack_tags[-1].with_child(tag)
    end

    tag
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

class Alumno
  attr_reader :nombre, :legajo

  def initialize(nombre, legajo, telefono)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
  end
end


unAlumno = Alumno.new("Matias","123456-8", "1234567890")
documento2 = Document.new
documento2.serialize(unAlumno)
puts documento2.xml


=begin
unEstado = Estado.new(3, 5, true)
unAlumno = Alumno.new("Matias","123456-8", "1234567890", unEstado)

variables = unAlumno.instance_variables
atributo = variables.first
mensaje = atributo.to_s.delete_prefix('@')
puts unAlumno.respond_to?(mensaje)
nombre = unAlumno.send(mensaje)
puts nombre.class
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