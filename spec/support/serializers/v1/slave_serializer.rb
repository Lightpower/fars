module V1
  class SlaveSerializer < Fars::BaseModelSerializer
    attributes :id, :name, :data, # attrs
               :updated_at # methods

    def updated_at
      '2014-04-14'
    end
  end
end
