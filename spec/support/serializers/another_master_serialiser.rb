class AnotherMasterSerializer < Fars::BaseModelSerializer
  self.model = Master
  self.root_key = :father
  attributes :id, :name, # attrs
             :number, # methods
             :slaves

  def number
    14
  end
end
