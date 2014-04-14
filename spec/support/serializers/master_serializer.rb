class MasterSerializer < Fars::BaseModelSerializer
  attributes :id, :name, :data, # attrs
             :slaves

  def meta
    { 'metadata' => :present }
  end
end
