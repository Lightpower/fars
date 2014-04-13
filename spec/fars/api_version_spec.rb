require 'spec_helper'

describe Fars::BaseModelSerializer do
  before :all do
    ActiveSupport::Inflector.inflections do |inflect|
      inflect.irregular 'slave', 'slaves'
    end

    class Master < ActiveRecord::Base
      has_many :slaves
    end
    class Slave < ActiveRecord::Base
      belongs_to :master
    end

    module V1
      class MasterSerializer < Fars::BaseModelSerializer
        attributes :id, :name, :data, # attrs
                   :slaves

        def meta
          {'metadata' => :present}
        end
      end
      class SlaveSerializer < Fars::BaseModelSerializer
        attributes :id, :name, :data # attrs
      end

      class MastersSerializer < Fars::BaseCollectionSerializer ; end
      class SlavesSerializer  < Fars::BaseCollectionSerializer ; end
    end
  end

  context '#to_json' do
    before :each do
      @object = Master.create(id: 1, name: 'Object1', data: '123')
      1.upto(2) {|i| Slave.create(id: i, master_id: @object.id, name: "Slave #{i}") }
    end

    it 'returns all fields with metadata' do
      json_data = {
        master: {id: 1, name: 'Object1', data: '123'},
        _metadata: {metadata: :present}
      }.to_json

      V1::MasterSerializer.new(
        @object,
        add_metadata: true,
        fields: [:id, :name, :data],
        api_version: 'V1'
      ).to_json.should == json_data
    end

    it 'returns not all field, whithout metadata' do
      json_data = {master: {id: 1, name: 'Object1'}}.to_json

      V1::MasterSerializer.new(
        @object,
        add_metadata: false,
        fields: [:id, :name],
        api_version: 'V1'
      ).to_json.should == json_data
    end

    it 'returns all field with slaves' do
      json_data = {master: {id: 1, name: 'Object1', data: '123',
        slaves: [
          {slave: {id: 1, name: 'Slave 1', data: nil}},
          {slave: {id: 2, name: 'Slave 2', data: nil}},
        ]}}.to_json

      V1::MasterSerializer.new(
        @object,
        add_metadata: false,
        fields: [:id, :name, :data, :slaves],
        api_version: 'V1'
      ).to_json.should == json_data
    end
  end
end
