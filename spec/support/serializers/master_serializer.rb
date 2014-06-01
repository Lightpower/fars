class MasterSerializer < Fars::BaseModelSerializer
  attributes :id, :name, :data, # attrs
             :slaves

  def available_attributes
    object.name == 'NO DATA' ? [:id, :name, :slaves] : all_attributes
  end

  def meta
    { 'metadata' => :present }
  end
end
