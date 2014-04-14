##
# Class: BaseCollectionSerializer
#
# It is used to represent collections
#
class Fars::BaseCollectionSerializer
  ##
  # Constructor
  #
  # Params:
  #   - objects {ActiveRecord::Relation} or {Array} collection to serialize
  #   - opts {Hash} of options:
  #     - fields {Array} of attributes to serialize. Can be {NilClass}.
  #       If so - will use all available.
  #     - scope {Object} context of request. Usually current user
  #       or current ability. Can be passed as a {Proc}. If so -
  #       evaluated only when actually called.
  #     - :add_metadata {Boolean} if to add a node '_metadata'
  #     - :root_key {Symbol} overwrites the default one from serializer's Class
  #     - :api_version {String} namespace for serializers classes, e.g. "V1"
  #     - :class_name {String} serialized model class name
  #     - :serializer {String} model serializer class name
  #     - :metadata {Hash} optional hash with metadata (root_key should not be false)
  #
  def initialize(objects, opts = {})
    @objects = objects
    if !opts.has_key?(:root_key) && !opts[:class_name] && empty_array?
      raise ArgumentError, 'Specify :root_key or model :class_name for empty array.'
    end
    # Cann't use Hash#fetch here, becouse if root_key provided default_root_key method should not be called.
    @root_key = opts.has_key?(:root_key) ? opts[:root_key] : default_root_key
    if !@root_key && opts[:metadata]
      raise ArgumentError, 'Can not omit :root_key if provided :metadata'
    end
    # Serialized model class name.
    @class_name = opts[:class_name]
    if opts[:serializer]
      if opts[:serializer].is_a? Proc
        @item_serializer = opts[:serializer]
      else
        @item_serializer_class = opts[:serializer].constantize
      end
    end
    @api_version = opts[:api_version]
    @params = opts[:params] || {}
    @metadata = opts[:metadata]
    # Do not need options if serialize items with proc.
    unless @item_serializer
      # Options for model serializer.
      @options = opts.slice(:scope, :fields, :add_metadata, :api_version, :params)
      # If root_key is false, do not transfer this option to the model serializer class.
      @options[:root_key] = item_root_key if @root_key
    end
  end

  ##
  # Returns: Hash
  #
  def as_json
    items = []

    unless empty_array?
      @item_serializer ||= item_serializer_class.new(nil, options)

      objects.each do |object|
        items << item_serializer.call(object)
      end
    end

    return items unless root_key

    hash = { root_key => items }
    hash[:_metadata] = metadata if metadata
    hash
  end

  def to_json
    MultiJson.dump(as_json)
  end

private

  attr_reader :objects, :options, :root_key, :api_version, :params, :metadata, :item_serializer

  ##
  # Checks if objets is not ActiveRecord::Relation and it's empty.
  # In this case impossible to obtain model's class name.
  #
  def empty_array?
    objects.is_a?(Array) && objects.empty?
  end

  ##
  # Returns: {String} ActiveRecord Model base_class name
  #
  def class_name
    @class_name ||= if objects.is_a?(ActiveRecord::Relation)
      objects.klass
    else
      objects.first.class
    end.base_class.to_s
  end

  ##
  # Returns: {Symbol}, requires @class_name
  #
  def default_root_key
    class_name.to_s.underscore.pluralize.to_sym
  end

  ##
  # Returns: {Symbol} or nil
  #
  def item_root_key
    root_key.to_s.singularize.to_sym if root_key
  end

  ##
  # Returns: {Class} of Model Serializer
  #
  def item_serializer_class
    @item_serializer_class ||= "#{api_version + '::' if api_version}#{class_name}Serializer".constantize
  end
end
