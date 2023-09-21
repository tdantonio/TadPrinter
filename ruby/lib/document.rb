require './ruby/lib/tag.rb'

class Document
  attr_accessor :proc, :cola_tags

  def initialize(&proc)
    @proc = proc
    @cola_tags = []
  end

  def xml
    tag_final = instance_eval(&proc)
    tag_final.xml
  end

  private def method_missing(name, *args, &proc)
    tag = Tag.with_label(name)

    add_atributos(tag, *args)

    cola_tags.push(tag)
    contenido = instance_eval(&proc)
    unless contenido.is_a? Tag
      tag.with_child(contenido)
    end
    cola_tags.pop

    unless cola_tags.empty?
      cola_tags[-1].with_child(tag)
    end

    tag
  end

  def add_atributos(tag, *args)

    unless args.empty?
      parametros = args.first
      parametros.each do |clave, valor|
        tag.with_attribute(clave, valor)
      end
    end
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

# Output:
# XML:
# <alumno nombre="Matias" legajo= "123456-7">
#   <telefono>1234567890</telefono>
#   <estado es_regular=true>
#      <finales_rendidos>3</finales_rendidos>
#      <materias_aprobadas>5<materias_aprobadas>
#   </estado>
# </alumno>

# Orden de ejecucion:
# documento = Document.new
# documento.tag =
# Tag.with_label('alumno').
#   with_attribute('nombre', 'Matias').
#   with_attribute('legajo', '123456-7').
#   with_child(
#     Tag.
#       with_label('telefono').
#       with_child('1234567890')).
#       with_child(
#           Tag.
#             with_label('estado').
#             with_attribute('es_regular', true).
#             with_child(
#               Tag.
#                 with_label('finales_rendidos').
#                 with_child('3')).
#                 with_child(
#                   Tag.
#                     with_label('materias_aprobadas').with_child('5')))
# puts documento.xml
