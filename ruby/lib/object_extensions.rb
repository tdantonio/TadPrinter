# object_extensions.rb

require_relative 'attribute'

class Object
=begin
  def normal_attributes_as_hash
    atributos = Hash.new

    getters
      .select { |getter| normal_attribute?(getter) }
      .each { |msj| atributos[msj] = send(msj) }

    atributos
  end
=end

=begin
  def getters
    instance_variables
      .map{ |atributo| atributo.to_s.delete_prefix('@') }
      .select{ |msj| respond_to? msj }
  end
=end

  def instance_variables_with_getters
    result = {}
    self.class.instance_methods(false).each do |method_name|
      if method_name.to_s.end_with?("=")
        # Skip setter methods
        next
      end


      if valid_identifier?(method_name) && respond_to?(method_name) && instance_variable_defined?("@#{method_name}")
        # Check if there's a corresponding getter method and instance variable
        value = instance_variable_get("@#{method_name}")
        result[method_name] = value
      end
    end
    result
  end

  def normal_attribute?(getter)
    send(getter).is_normal?
  end

  def valid_identifier?(name)
    # Check if the name consists of valid characters and is not a Ruby reserved word.
    /^[a-zA-Z_]\w*$/.match?(name) && !name.match?(/\A(class|def|end|module|if|else|elsif|while|for|case|when|do|begin|rescue|ensure|unless|retry|break|next|return|super|self|true|false|nil)\z/)
  end


  def is_normal?
    normal_classes = [String, FalseClass, TrueClass, NilClass, Numeric]
    normal_classes.any?{ |normal_class| is_a? normal_class }
  end

=begin
  def children
    getters
      .select{|getter| !normal_attribute?(getter) }
      .flatten #[1,2,[3,4]] -> [1,2,3,4]
      .map{|getter| send(getter)}
  end
=end
end
