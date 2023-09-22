describe Punto2 do

  describe '#xml' do
    it 'debería pasar este test' do
      unAlumno = Alumno.new("Matias","123456-8", "1234567890")
      documento = Document.serialize(unAlumno)
      tag = Tag.with_label('alumno')
               .with_attribute('nombre','matias')
               .with_attribute('legajo', '123456-7')
      expect(documento.xml).to eq(tag.xml)
    end
  end
end