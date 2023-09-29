require_relative 'tag_creator'

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

=begin
  def self.automatic_proc(objects)
    proc do
        objects.each { |object|
          send(object.class.to_s.downcase, object.normal_attributes_as_hash, &Document.automatic_proc(object.children)) # TODO: testear si es lo mismo pasarlo como bloque
        }
    end
  end
=end
end


#testeo objects
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

estado = Estado.new(3, %w[dds so], true)
alumno = Alumno.new("Matias","123456-8", "1234567890", estado)
documento = Document.new
documento.serialize(alumno)
puts documento.xml


#testeo blocks
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

