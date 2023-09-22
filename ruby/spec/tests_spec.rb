describe Document do
  describe '#xml' do

    it 'Punto 1' do
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

    it 'Punto 2: documento_manual == documento_automatico' do
      estado = Estado.new(3, 5, true) # TODO: No se pone en orden correcto, chequear implementación
      alumno = Alumno.new("Matias","123456-8", "1234567890", estado)
      documento_automatico = Document.serialize(alumno)
      tag = Tag.with_label('alumno')
               .with_attribute('nombre','Matias')
               .with_attribute('legajo', '123456-8')
               .with_child(
                 Tag.with_label('estado')
                    .with_attribute('finales_rendidos', 3)
                    .with_attribute('es_regular', true)
                    .with_attribute('materias_aprobadas', 5)
                 )
      expect(documento_automatico.xml).to eq(tag.xml)
    end
  end
end