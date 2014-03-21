##
# Class: BaseCollectionSerializer
#
# It is used to represent collections
#
class Fars::BaseCollectionSerializer
  def initialize(objects, opts={})
    @objects      = objects
    @scope        = opts[:scope]
    @fields       = opts[:fields]
    @add_metadata = opts[:add_metadata]
    @root_key     = opts.fetch(:root_key, get_root_key)
    @api_version  = opts[:api_version]
    @item_serializer_class = get_item_serializer_class
  end

  def as_json
    items = []

    the_class = item_serializer_class.new(nil,
                                         scope:        @scope,
                                         add_metadata: add_metadata,
                                         fields:       fields,
                                         root_key:     get_instance_root_key
                                        )

    objects.each do |object|
      items << the_class.with_object(object).as_json
    end

    root_key ? {root_key => items} : items
  end

  def to_json
    MultiJson.dump(as_json)
  end

private

  attr_reader :api_version, :objects, :scope, :fields, :add_metadata, :root_key, :item_serializer_class

  def get_root_key
    (self.to_s.match /#{api_prefix}(\w+)Serializer/)[1].underscore.to_sym
  end

  def get_instance_root_key
    # If root_key is false, get a real one
    (root_key || get_root_key).to_s.singularize.to_sym
  end

  def get_item_serializer_class
    (self.class.to_s.gsub('Serializer', '').singularize + 'Serializer').constantize
  end

  # Returns {String} prefix for serializer class name using API version
  def api_prefix
    @api_version ? @api_version + '::' : ''
  end
end
