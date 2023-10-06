# attribute.rb

module Attribute
  def initialize(name, value)
    @name = name
    @value = value
  end

end

class AttributeWithGetter

  include Attribute

  def adopt_itself(parent)
    parent.with_attribute(@name, @value)
  end

end

class ArrayAttribute

  include Attribute

  def initialize(name, value)
    super(name, value)
    @tag = Tag.with_label(name)
  end

  def add_children
    @value.each do |child|
      if child.is_normal?
        new_tag = Tag.with_label(child.class.to_s.downcase)
        new_tag.with_child(child)
      else
        new_tag = TagCreatorObjects.new(child).tag

    end
      @tag.with_child(new_tag)
    end
  end

  def adopt_itself(parent)
    add_children
    parent.with_child(@tag)
  end



end


class ObjectAttribute

  include Attribute

  def adopt_itself(parent)
    parent.with_child(TagCreatorObjects.new(@value).tag)
  end

end
