module Fars::ObjectSerializable
  def serialize(opts = {})
    api_prefix = opts[:api_version] + '::' if opts[:api_version]
    serializer_class = (opts[:serializer] || "#{api_prefix}#{self.class}Serializer").constantize
    serializer_class.new(self, opts).to_json
  end
end
