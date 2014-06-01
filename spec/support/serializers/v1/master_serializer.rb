module V1
  class MasterSerializer < Fars::BaseModelSerializer
    attributes :id, :name, :data, # attrs
               :updated_at, # methods
               :slaves

    def updated_at
      '2014-04-14'
    end

    def available_attributes
      object.name == 'NO DATA' ? [:id, :name, :updated_at, :slaves] : all_attributes
    end

    def meta
      { 'metadata' => :present }
    end
  end
end
