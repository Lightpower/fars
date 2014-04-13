##
# Class: BaseObjectSerializer
#
class Fars::BaseObjectSerializer
  class << self
    attr_accessor :root_key, :api_version
  end

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
    raise NotImplementedError, 'Fars::BaseObjectSerializer#as_json must be implemented in inherited class'
  end

  def to_json
    MultiJson.dump(as_json)
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
end
