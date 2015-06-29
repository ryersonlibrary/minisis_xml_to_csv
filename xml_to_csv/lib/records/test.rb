class Nested
  include SAXMachine
  element :first
  element :second

  def to_s
    "#{send(:first)} + #{send(:second)}"
  end
end

class Test
  include SAXMachine

  @@maps = {
    multiple: %i[_multiple],
    multiple_nested: %i[_multiple_nested],
    merge: %i[_merge1 _merge2],
  }

  # overload class method
  def self.column_names
    super - @@maps.values.flatten + @@maps.keys
  end

  # mapping for element (single instance)
  element :single, as: :id

  # mapping for element (multiple instances)
  elements :multiple, as: :_multiple
  def multiple(concat = '|')
    @@maps[:multiple].map { |s| send(s) }.compact.join(concat)
  end

  # mapping for nested elements (single instance)
  element :nested, class: Nested

  # mapping for nested elements (multiple instance)
  elements :multiple_nested, as: :_multiple_nested, class: Nested
  def multiple_nested(concat = '|')
    @@maps[:multiple_nested].map { |s| send(s) }.compact.join(concat)
  end

  # mapping multiple elements to single column
  element :merge1,  as: :_merge1
  element :merge2,  as: :_merge2
  def merge(concat = '|')
    @@maps[:merge].map {|s| send(s)}.compact.join(concat)
  end

end