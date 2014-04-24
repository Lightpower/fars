class StatSerializer < Fars::BaseObjectSerializer
  def as_json
    { stat_key: object[0], stat_value: object[1] }
  end
end
