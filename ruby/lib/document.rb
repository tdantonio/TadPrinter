# frozen_string_literal: true
require 'A:\Universidad\Tercer año\TADP\grupo3-2023-2c\ruby\lib\tag.rb'

class Document
  attr_reader :proc, :tag

  def initialize(&proc)
    @proc = proc
  end

  def xml
    instance_eval(&proc)
    tag.xml
  end

  private def method_missing(name, *args, &bloque)
    @tag = Tag.with_label(name)
    puts "name: #{name}"

    parametros = args.first
    parametros.each do |clave, valor|
      # puts "clave: #{clave}; valor: #{valor}"
      @tag.with_attribute(clave, valor)
    end

    @tag.with_child(Tag.with_label(bloque))
  end
end

documento = Document.new do
  alumno nombre: "Matias", legajo: "123456-7" do
    telefono { "1234567890" }
  end

end

puts documento.xml

###############################
# Ruby:
# documento = Document.new do
# 	alumno nombre: "Matias", legajo: "123456-7" do
# 		telefono { "1234567890" }
#     estado es_regular: true {
#       finales_rendidos { 3 }
#       materias_aprobadas { 5 }
#     }
# 	end
# end
#
#
# XML:
# <alumno nombre="Matias" legajo= "123456-7">
#   <telefono>1234567890</telefono>
#   <estado es_regular=true>
#      <finales_rendidos>3</finales_rendidos>
#      <materias_aprobadas>5<materias_aprobadas>
#   </estado>
# </alumno>

=begin
Tag
  .with_label('alumno')
  .with_attribute('nombre', 'Mati')
  .with_attribute('legajo', '123456-7')
  .with_attribute('edad', 27)
  .with_child(
    Tag
      .with_label('telefono')
      .with_child('12345678')
  )
  .with_child(
    Tag
      .with_label('estado')
      .with_child(
        Tag
          .with_label('value')
          .with_child('regular')
      )
  )
  .with_child(Tag.with_label('no_children'))
  .xml
=end
