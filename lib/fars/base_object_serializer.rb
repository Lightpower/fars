##
# Class: BaseObjectSerializer
#
class Fars::BaseObjectSerializer
  class << self
    def attributes(*attrs)
      @attributes = attrs.map(&:to_sym)
    end

    def all_attributes
      @attributes
    end

    ##
    # Returns: {Class} of serialized model (can be nil)
    #
    def model
      @model ||= begin
        @class_name ||= self.to_s.sub(/^V\d+::/, '').sub(/Serializer$/, '')
        @class_name.constantize if Object.const_defined?(@class_name)
      end
    end
    attr_writer :model

    ##
    # Returns: {Symbol} instance hash root key, as an underscored Model name
    #
    def root_key
      @root_key ||= (model ? model.to_s.underscore.to_sym : nil)
    end
    attr_writer :root_key

    ##
    # Returns: {String} capitalized API version (can be nil)
    #
    def api_version
      namespace_array = name.split('::')
      namespace_array.size > 1 ? namespace_array[0] : nil
    end

    ##
    # Returns: {Array} with names of this serializer instance methods. Consists of Symbols
    # Filtrated by #all_attributes
    #
    def serializer_methods
      @serializer_methods ||= self.instance_methods & all_attributes
    end
  end

  ##
  # Initialize new instance
  #
  # Params:
  #   - object {ActiveRecord::Base} or any {Object} to serialize
  #   - opts {Hash} of options:
  #     - fields {Array} of attributes to serialize. Can be {NilClass}.
  #       If so - will use all available.
  #     - scope {Object} context of request. Usually current user
  #       or current ability. Can be passed as a {Proc}. If so -
  #       evaluated only when actually called.
  #     - :add_metadata {Boolean} if to add a node '_metadata'
  #     - :root_key {Symbol} overwrites the default one from serializer's Class
  #
  def initialize(object, opts = {})
    @object       = object
    @scope        = opts[:scope]
    @fields       = opts[:fields]
    @add_metadata = opts.fetch(:add_metadata, self.respond_to?(:meta))
    @root_key     = opts.fetch(:root_key, self.class.root_key)
    @api_version  = opts.fetch(:api_version, self.class.api_version)
    @params       = opts[:params] || {}
  end

  def with_object(object)
    @object = object
    self
  end

  def as_json
    all_attrs = available_attributes
    item = {}
    (all_attrs - requested_serializer_methods).each do |m|
      item[m] = object.public_send(m)
    end
    (all_attrs & requested_serializer_methods).each do |m|
      item[m] = self.public_send(m)
    end
    hash = { root_key => item }
    hash[:_metadata] = meta if add_metadata?
    hash
  end

  def to_json
    MultiJson.dump(as_json)
  end

  def call(obj)
    with_object(obj).as_json
  end

private

  # Things we get from options
  attr_reader :object, :fields, :root_key, :api_version, :params

  def scope
    if @scope.is_a? Proc
      @scope = @scope.call
    else
      @scope
    end
  end

  def add_metadata?
    @add_metadata
  end

  delegate :all_attributes, :serializer_methods, to: :'self.class'

  def requested_serializer_methods
    @requested_serializer_methods ||= serializer_methods & requested_attributes
  end

  ##
  # List of attributes requested to be shown.
  # This is frequently done by :fields HTTP request
  # parameter
  #
  def requested_attributes
    @requested_attributes ||= begin
      case fields
      when NilClass then all_attributes
      when Array    then fields.map(&:to_sym) | [:id]
      when Symbol   then [fields]
      when String   then [fields.to_sym]
      end
    end
  end

  ##
  # List of attributes available to be shown
  # by current security context.
  #
  # Can be re-defined in inherited class
  #
  alias_method :available_attributes, :all_attributes
end
