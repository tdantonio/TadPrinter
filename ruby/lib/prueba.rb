module ComportamientoComun
  def mensaje_comun
    puts "Este es un mensaje común desde ComportamientoComun"
  end
end

module Modulo1
  class << self
    include ComportamientoComun
  end

  # Otros métodos específicos de Modulo1
end

module Modulo2
  class << self
    include ComportamientoComun
  end

  # Otros métodos específicos de Modulo2
end

=begin
Modulo1.mensaje_comun
Modulo2.mensaje_comun
=end


module A
  def m
    puts "HOLA"
  end
end

module B
  class << self
    include A
  end
end

B.m