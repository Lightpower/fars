##
# Class: BaseModelSerializer
#
# Naming convention: <Name of Model, singular!>Serializer
#
# Ways to use:
#   - create new instance, call to_json
#   - create new instance, add objects to serialize one by one.
#     This lets you reuse it without determining known data
#
class Fars::BaseModelSerializer < Fars::BaseObjectSerializer
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
      @model ||= self.to_s.sub(/^V\d+::/, '').sub(/Serializer$/, '').constantize
    end
    attr_writer :model

    ##
    # Returns: {Symbol} instance hash root key, as an underscored Model name
    #
    def root_key
      @root_key ||= model.to_s.underscore.to_sym
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
    # Returns: {Array} with names of Model relations. Consists of Symbols.
    # Filtrated by #all_attributes
    #
    def model_relations
      @model_relations ||= (model.reflect_on_all_associations.map { |r| r.name.to_sym } - serializer_methods) & all_attributes
    end

    ##
    # Returns: {Array} with names of Model methods. Consists of Symbols
    # Filtrated by #all_attributes
    #
    def model_methods
      @model_methods ||= ((model.attribute_names.map(&:to_sym) | model.instance_methods) - model_relations - serializer_methods) & all_attributes
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
  #   - object {ActiveRecord::Base} to serialize
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
    super

    @all_attributes     = self.class.all_attributes
    @object_relations   = self.class.model_relations
    @object_attributes  = self.class.model_methods
    @serializer_methods = self.class.serializer_methods
  end

  def as_json
    # as we can re-use one class of serializer for
    # many objects, we need to re-evaluate list
    # of available_attributes for each of them
    all_attrs = available_attributes
    item      = {}

    (requested_object_attributes & all_attrs).each do |attr|
      item[attr] = object.send(attr)
    end

    (requested_serializer_methods & all_attrs).each do |meth|
      item[meth] = self.send(meth)
    end

    (requested_object_relations & all_attrs).each do |rel|
      item[rel] = serialize_relation(rel)
    end

    hash = { root_key => item }
    hash[:_metadata] = meta if add_metadata?
    hash
  end

private

  ##
  # Serializes object's relation
  #
  # Returns: {Hash}
  #
  def serialize_relation(relation_name, relation = nil)
    relation ||= object.public_send(relation_name)
    ::Fars::BaseCollectionSerializer.new(relation,
      root_key: false,
      scope: @scope,
      add_metadata: add_metadata?,
      api_version: api_version).as_json
  end

  # Sets of attributes/methods/relations
  attr_reader :all_attributes, :object_attributes, :serializer_methods, :object_relations

  ##
  # List of attributes requested to be shown.
  # This is frequently done by :fields HTTP request
  # parameter
  #
  def requested_attributes
    @requested_attributes ||= get_requested_attributes
  end

  def requested_object_attributes
    @requested_object_attributes  ||= object_attributes & requested_attributes
  end

  def requested_serializer_methods
    @requested_serializer_methods ||= serializer_methods & requested_attributes
  end

  def requested_object_relations
    @requested_object_relations   ||= object_relations & requested_attributes
  end

  ##
  # List of attributes available to be shown
  # by current security context.
  #
  # Can be re-defined in inherited class
  #
  def available_attributes
    all_attributes
  end

  def get_requested_attributes
    case fields
      when NilClass then all_attributes
      when Array    then fields.map(&:to_sym) | [:id]
      when Symbol   then [fields]
      when String   then [fields.to_sym]
    end
  end
end
