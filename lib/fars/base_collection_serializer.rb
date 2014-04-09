##
# Class: BaseCollectionSerializer
#
# It is used to represent collections
#
class Fars::BaseCollectionSerializer
  def initialize(objects, opts = {})
    @objects      = objects
    @options      = opts
    @root_key     = opts.fetch(:root_key, get_root_key)
    @item_serializer_class = get_item_serializer_class
  end

  def as_json
    the_class = item_serializer_class.new(nil, options.merge({ root_key: get_instance_root_key }))

    items = objects.map do |object|
      the_class.with_object(object).as_json
    end

    root_key ? { root_key => items } : items
  end

  def to_json
    MultiJson.dump(as_json)
  end

private

  attr_reader :objects, :options, :root_key, :item_serializer_class

  def get_root_key
    self.class.to_s.demodulize.sub('Serializer', '').underscore.to_sym
  end

  def get_instance_root_key
    # If root_key is false, get a real one
    (root_key || get_root_key).to_s.singularize.to_sym
  end

  def get_item_serializer_class
    (self.class.to_s.gsub('Serializer', '').singularize + 'Serializer').constantize
  end
end
