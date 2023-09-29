# frozen_string_literal: true

class Label
  def initialize(label)
    @label = label
    Annotator.add_pending_annotation(self)
  end

  def evaluate(clase)
    label = @label # TODO: Hardcodeado nashe
    clase.define_method(:label) { label }
  end
end