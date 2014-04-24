class ColorSerializer < Fars::BaseObjectSerializer
  def as_json
    { color: object }
  end
end
