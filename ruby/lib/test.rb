# frozen_string_literal: true


=begin
class Class
  def initialize
    puts "self.name: #{self.name}"
  end

  alias_method :old_new, :new

  def self.new
    puts "self en new: #{self}"
    old_new
  end
end
=end

class A
  class B
    def m
      "hola"
    end
  end
end

A::B.new.m

=begin
B = Class.new
B.define_method(:m) {"hola"}
=end


def method_missing(annotation_name, *args)
  # if '✨' == annotation_name[0] and ✨ == annotation_name[-1]
  if annotation_name.match? "✨.*✨"
    Object.const_get(annotation_name.to_s.gsub('✨','')).new(*args)
  else
    super(annotation_name, *args)
  end
end


class Label
  def initialize(new_name)
    puts new_name
    # Convert tag_name to name
  end
end

class Ignore
  def initialize()
    puts "Ignore"
    #Ignore getter or class
  end
end


class Inline
  def initialize(&proc)
    instance_eval &proc
    # redefine getter to the given block
    # pass getter to the block and create the new attribute
  end
end

class Custom
  def initialize(&proc)
    instance_eval &proc
  end
end



✨Ignore✨
class Alumno

  attr_reader :nombre, :legajo, :telefono

  ✨Label✨("situacion")
  attr_reader :estado

  def initialize(nombre, legajo, telefono, estado)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
  end

end