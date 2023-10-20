trace = TracePoint.new(:class) do |tp|
  p [tp.lineno, tp.event, tp.self]
end
#=> #<TracePoint:disabled>

trace.enable
#=> false

class PRUEBA

end

module ModuloFalopa

end
class PRUEBA

end

class String

end