# frozen_string_literal: true

class Annotator # Tiene que definirse antes de agregarle el hook inherited a Class
  @pending_annotations = []
  def self.add_pending_annotation(annotation)
    @pending_annotations << annotation
  end

  def self.add_pending_annotations_to(clase)
    @pending_annotations.each do |annotation|
      annotation.evaluate(clase)
    end
    @pending_annotations = []
  end
end

class Class
  def inherited(subclass)
    Annotator.add_pending_annotations_to(subclass)
  end
end

# Sigue habiendo un poco de repetición de lógica
class << self
  def ✨Label✨(new_label)
    Label.new(new_label)
  end

  def ✨Ignore✨
    Ignore.new
  end

  def ✨Custom✨(&proc)
    Custom.new(&proc)
  end
end