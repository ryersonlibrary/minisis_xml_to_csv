class OriginationGroup
  include SAXMachine

  element :ORIGINATOR
  element :EAD_LABEL
  element :EAD_ROLE

  def to_s
    return self.class.column_names.map { |col| send(col) }.compact.join("|")
  end
end