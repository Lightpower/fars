require 'spec_helper'

describe Fars::BaseModelSerializer do
  before :all do
    class Master < ActiveRecord::Base
      has_many :slaves
    end

    class MasterSerializer < Fars::BaseModelSerializer
      attributes :id, :name, :data # attrs
    end
  end

  context '#to_json' do
    before :each do
      @object = Master.create(id: 1, name: 'Object1', data: '123')
      @fields = [:id, :name, :data]
      @json = {master: {id: 1, name: 'Object1', data: '123'}}.to_json
    end

    it 'represent as json' do
      MasterSerializer.new(@object, add_metadata: false, fields: @fields).to_json.should == @json
    end
  end
end
