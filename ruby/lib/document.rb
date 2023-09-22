require './ruby/lib/tag.rb'

class Document

  def initialize(&proc)
    @stack_tags = []
    @tag_final = instance_eval(&proc)
    # @tag_final = instance_exec &proc # Funciona igual
  end

  def xml
    @tag_final.xml
  end

  private def method_missing(name, *args, &proc)
    tag = Tag.with_label(name)

    tag.with_attributes(args.empty? ? [] : args.first)

    @stack_tags.push(tag)
    contenido = instance_eval(&proc)
    # contenido = instance_exec &proc # Funciona igual
    unless contenido.is_a? Tag
      tag.with_child(contenido)
    end
    @stack_tags.pop

    unless @stack_tags.empty?
      @stack_tags[-1].with_child(tag)
    end

    tag
  end

  def self.serialize(object)
=begin
    @tag_final = Tag.with_label(objeto.class.to_s.downcase)

    # Se obtienen los atributos del objeto y se meten en un hash
    getters = objeto.instance_variables.map{ |a| a.to_s.delete_prefix('@')}.select{|m| objeto.respond_to?m}
    atributos = Hash.new
    getters.each { |m| atributos[m] = objeto.send(m) }

    # A partir del Hash se agregar los atributos al tag
    with_attributes(@tag_final, atributos)
=end

=begin
    Document.new do
      send(object.class.to_s.downcase, object.normal_attributes_as_hash) &Document.proc_automatico(object.children)
    end
=end
    Document.new &Document.proc_automatico([object])
  end

  def self.proc_automatico(objects)
    proc do
      # No funciona porque "each" devuelve la lista de objetos, y solo queremos que devuelva lo que devuelve send
      # objects.each{ |unObjeto| send(unObjeto.class.to_s.downcase, unObjeto.normal_attributes_as_hash) {  } }

      # Ídem "each", pero ahora lo hace el "for"
=begin
      for unObjeto in objects
        send(unObjeto.class.to_s.downcase, unObjeto.normal_attributes_as_hash) &Document.proc_automatico(unObjeto.children)
      end
=end

      # Rompe cuando quiere evaluar &Document.proc_automatico(unObjeto.children)
      puts "objects[0]: #{objects[0]}"
      unObjeto = objects[0]
      send(unObjeto.class.to_s.downcase, unObjeto.normal_attributes_as_hash) &Document.proc_automatico(unObjeto.children)
    end
  end

end


class Object
  def normal_attributes_as_hash
    atributos = Hash.new

    getters
      .select { |getter| normal?(getter) }
      .each { |msj| atributos[msj] = send(msj) }

    atributos
  end

  def getters
    instance_variables
      .map{ |atributo| atributo.to_s.delete_prefix('@') }
      .select{ |msj| respond_to? msj }
  end

  def normal?(getter)
    [String, FalseClass, TrueClass, NilClass, Numeric].include?(send(getter).class)
  end

  def children
    getters
      .select{|getter| !normal?(getter)}
      .flatten #[1,2,[3,4]] -> [1,2,3,4]
      .map{|getter| send(getter)}
  end
end


class Alumno
  attr_reader :nombre, :legajo

  def initialize(nombre, legajo, telefono)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
  end
end


unAlumno = Alumno.new("Matias","123456-8", "1234567890")
documento = Document.serialize(unAlumno)
puts documento.xml

=begin
proc = Document.proc_automatico(unAlumno.children)
puts "Antes"
proc.call
puts "Despues"
=end

###########
# Punto 1 #
###########
documento = Document.new do
  alumno nombre: "Matias", legajo: "123456-7" do
    telefono { "1234567890" }
    estado es_regular: true do
      finales_rendidos { 3 }
      materias_aprobadas { 5 }
    end
  end
end




