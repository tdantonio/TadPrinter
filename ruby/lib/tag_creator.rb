# tag_creator.rb

require_relative 'attribute'
require_relative 'tag'
require_relative 'object_extensions'

module TagCreator

  attr_reader :tag

  def initialize(input)
    @contenido = evaluate(input)
  end

end

class TagCreatorBlocks
  include TagCreator
  attr_reader :tags

  def initialize(input, first_one = false)
    @tags = []
    super(input)
    if @contenido.is_normal?
      @tags << @contenido
    end
    if first_one
      @tag = @tags.first
    end
  end


  private def method_missing(name, *args, &block)

    new_tag = Tag.with_label(name)
    new_tag.with_attributes(args.empty? ? [] : args.first)

    if block_given?
      new_tag.with_children(TagCreatorBlocks.new((Proc.new &block)).tags)
    end

    @tags << new_tag

  end

  def evaluate(input)
    instance_eval &input
  end



end


class TagCreatorObjects
  include TagCreator

  def initialize(input)
    @tag = Tag.with_label(input.class.to_s.downcase)
    super(input)
  end

  def evaluate(object)
    @instance_attributes = object.instance_variables_with_getters
    @instance_attributes.each do |name, value|
      factory_attributes(name, value).adopt_itself(@tag)

    end

  end

  def factory_attributes(name, value)
    if value.is_a? Array
      ArrayAttribute.new(name, value)
    elsif value.is_normal?
      AttributeWithGetter.new(name, value)
    else
      ObjectAttribute.new(name, value)
    end
  end
end
