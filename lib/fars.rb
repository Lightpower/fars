require 'active_record'

module Fars; end
require 'fars/base_object_serializer'
require 'fars/base_model_serializer'
require 'fars/base_collection_serializer'
require 'fars/model_serializable'
require 'fars/relation_serializable'

class ActiveRecord::Base
  include Fars::ModelSerializable
end

class ActiveRecord::Relation
  include Fars::RelationSerializable
end

class Array
  include Fars::RelationSerializable
end

class Hash
  include Fars::RelationSerializable
end
