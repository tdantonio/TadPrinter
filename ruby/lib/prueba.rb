class A
  def modify_class(clase)
    clase.define_method(:nombre) do
      puts "mi nombre es: #{self}"
    end
  end
end

a = A.new

class B
end

a.modify_class(B)

B.new.nombre
