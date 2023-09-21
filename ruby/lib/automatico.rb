# frozen_string_literal: true

class Automatico < Document
  def serialize(objeto)
    @root_tag = Tag.with_label(objeto.class.to_s.downcase)

    # Se obtienen los atributos del objeto y se meten en un hash
    getters = objeto.instance_variables.map{ |a| a.to_s.delete_prefix('@')}.select{|m| objeto.respond_to?m}
    atributos = Hash.new
    getters.each { |m| atributos[m] = objeto.send(m) }

    # A partir del Hash se agregar los atributos al tag
    with_attributes(@root_tag, atributos)

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
documento2 = Document.new
documento2.serialize(unAlumno)
puts documento2.xml




unEstado = Estado.new(3, 5, true)
unAlumno = Alumno.new("Matias","123456-8", "1234567890", unEstado)

variables = unAlumno.instance_variables
atributo = variables.first
mensaje = atributo.to_s.delete_prefix('@')
puts unAlumno.respond_to?(mensaje)
nombre = unAlumno.send(mensaje)
puts nombre.class
