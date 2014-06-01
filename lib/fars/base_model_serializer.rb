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
    ##
    # Returns: {Array} with names of Model methods. Consists of Symbols
    # Filtrated by #all_attributes
    #
    def model_methods
      @model_methods ||= ((model.attribute_names.map(&:to_sym) | model.instance_methods) - model_relations - serializer_methods) & all_attributes
    end

    ##
    # Returns: {Array} with names of Model relations. Consists of Symbols.
    # Filtrated by #all_attributes
    #
    def model_relations
      @model_relations ||= (model.reflect_on_all_associations.map { |r| r.name.to_sym } - serializer_methods) & all_attributes
    end
  end

  def as_json
    # as we can re-use one class of serializer for
    # many objects, we need to re-evaluate list
    # of available_attributes for each of them
    all_attrs = available_attributes
    item = {}
    (requested_model_methods & all_attrs).each do |attr|
      item[attr] = object.public_send(attr)
    end
    (requested_serializer_methods & all_attrs).each do |meth|
      item[meth] = self.public_send(meth)
    end
    (requested_model_relations & all_attrs).each do |rel|
      item[rel] = serialize_relation(rel)
    end
    return item unless root_key
    hash = { root_key => item }
    hash[:_metadata] = meta if add_metadata?
    hash
  end

private

  delegate :model_relations, :model_methods, to: :'self.class'

  def requested_model_methods
    @requested_model_methods ||= model_methods & requested_attributes
  end

  def requested_model_relations
    @requested_model_relations ||= model_relations & requested_attributes
  end

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

  ##
  # Requested fields.
  # If fields is Array ads primary_key attribute.
  #
  def fields
    @fields_with_id ||= begin
      return unless @fields
      if @fields.is_a?(Array)
        @fields | [self.class.model.primary_key.to_sym]
      else
        @fields
      end
    end
  end
end
