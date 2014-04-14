module V1
  class MasterSerializer < Fars::BaseModelSerializer
    attributes :id, :name, :data, # attrs
               :updated_at, # methods
               :slaves

    def updated_at
      '2014-04-14'
    end

    def meta
      { 'metadata' => :present }
    end
  end
end
