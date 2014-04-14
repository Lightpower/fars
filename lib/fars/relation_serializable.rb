module Fars::RelationSerializable
  def serialize(opts = {}, &block)
    Fars::BaseCollectionSerializer.new(self, opts, &block).to_json
  end
end
