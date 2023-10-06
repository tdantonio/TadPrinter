describe Document do
  context 'Punto 1' do
    it 'DLS correcto' do
      documento = Document.new do
        alumno nombre: "Matias", legajo: "123456-7" do
          telefono { "1234567890" }
          estado es_regular: true do
            finales_rendidos { 3 }
            materias_aprobadas { 5 }
          end
        end
      end
      tag = Tag.with_label('alumno')
               .with_attribute('nombre', 'Matias')
               .with_attribute('legajo', '123456-7')
               .with_child(
                 Tag.with_label('telefono')
                    .with_child('1234567890')
               )
               .with_child(
                 Tag.with_label('estado')
                    .with_attribute('es_regular', true)
                    .with_child(
                      Tag.with_label('finales_rendidos')
                         .with_child(3)
                    )
                    .with_child(
                      Tag.with_label('materias_aprobadas')
                         .with_child(5)
                    )
               )
      expect(documento.xml).to eq(tag.xml)
    end

    it 'DLS correcto 2' do
      documento = Document.new do
        alumno nombre: "Matias", legajo: "123456-7" do
          telefono numero: "123456"
          estado do
            finales_rendidos { 3 }
            materias_aprobadas { 5 }
          end
        end
      end

      tag = Tag.with_label('alumno')
                 .with_attribute("nombre", "Matias")
                 .with_attribute("legajo", "123456-7")
                 .with_child(
                   Tag.with_label("telefono")
                      .with_attribute("numero", "123456")
                 )
                 .with_child(
                   Tag.with_label("estado")
                      .with_child(
                        Tag.with_label("finales_rendidos")
                           .with_child(3)
                      )
                      .with_child(
                        Tag.with_label("materias_aprobadas")
                           .with_child(5)
                      )
                 )
      expect(documento.xml).to eq(tag.xml)
    end
  end

  context 'Punto 2' do
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

    it 'documento_manual == documento_automatico' do
      unEstado = Estado.new(3, 5, true) # TODO: No se pone en orden correcto, chequear implementación
      unAlumno = Alumno.new("Matias", "123456-8", "1234567890", unEstado)
      documento_automatico = Document.serialize(unAlumno)
      tag = Tag.with_label('alumno')
               .with_attribute('nombre', 'Matias')
               .with_attribute('legajo', '123456-8')
               .with_child(
                 Tag.with_label('estado')
                    .with_attribute('finales_rendidos', 3)
                    .with_attribute('materias_aprobadas', 5)
                    .with_attribute('es_regular', true)
               )

      documento_manual = Document.new do
        alumno nombre: unAlumno.nombre, legajo: unAlumno.legajo do
          estado finales_rendidos: unAlumno.estado.finales_rendidos,
                 materias_aprobadas: unAlumno.estado.materias_aprobadas,
                 es_regular: unAlumno.estado.es_regular
        end
      end

      # puts "\n\n" + documento_automatico.xml + "\n\n"
      # puts "\n\n" + documento_manual.xml + "\n\n"

      expect(documento_automatico.xml).to eq(documento_manual.xml)
      #expect(documento_manual.xml).to eq(tag.xml)
    end
  end

  context 'Punto 3' do
    it 'La annotation Label cambia la label de las clases, atributos e hijos' do
      tag = Tag.with_everything("estudiante", { nombre: "Matias", legajo: "123456-7", celular: "1234567890" }, [
        Tag.with_everything("situacion", { finales_rendidos: 3, materias_aprobadas: 5, es_regular: true }, [])])

      unEstado = TestEstadoLabel.new(3, 5, true) # TODO: No se pone en orden correcto, chequear implementación
      unAlumno = TestAlumnoLabel.new("Matias", "123456-7", "1234567890", unEstado)
      expect(Document.serialize(unAlumno).xml).to eq(tag.xml)
    end

    it 'La annotation ignore hace que se ignoren los atributos que la tienen o que sean instancias de una clase que la tiene' do
      tag = Tag.with_label("testalumnoignore").with_attribute(:legajo, "123456-7")

      unEstado = TestEstadoIgnore.new(3, 5, true)
      unAlumno = TestAlumnoIgnore.new("Matias", "123456-7", "1234567890", unEstado, "12345678")
      expect(Document.serialize(unAlumno).xml).to eq(tag.xml)
    end

    it 'La annotation custom cambia la forma de serializar hijos' do
      tag = Tag.with_everything("testalumnocustom", { nombre: "Matias", legajo: "123456-7", telefono: "1234567890" }, [
        Tag.with_everything("testestadocustom", {}, [
          Tag.with_label("regular").with_child(true),
          Tag.with_label("pendientes").with_child(2)
        ])
      ])

      unEstado = TestEstadoCustom.new(3, 5, true)
      unAlumno = TestAlumnoCustom.new("Matias", "123456-7", "1234567890", unEstado)

      expect(Document.serialize(unAlumno).xml).to eq(tag.xml)
    end

    it 'La annotation inline serializa hijos como atributos' do
      tag = Tag.with_everything("testalumnoinline", {nombre: "MATIAS", legajo: "123456-7", estado: true}, [])

      unEstado = TestEstadoInline.new(5, 3, true)
      unAlumno = TestAlumnoInline.new("matias", "123456-7", "1234567890", unEstado)

      expect(Document.serialize(unAlumno).xml).to eq(tag.xml)
    end
  end
end
