module Fars::RelationSerializable
  def serialize(opts = {})
    Fars::BaseCollectionSerializer.new(self, opts).to_json
  end
end
