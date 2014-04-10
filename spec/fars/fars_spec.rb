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

  context '#to_json' do
    before :each do
      @object = Master.create(id: 1, name: 'Object1', data: '123')
      2.times.each {|i| Slave.create(id: i+1, master_id: @object.id, name: "Slave #{i+1}") }
    end

    it 'returns all fields with metadata' do
      json_data = {
        master: {id: 1, name: 'Object1', data: '123'},
        _metadata: {metadata: :present}
      }.to_json

      MasterSerializer.new(
        @object,
        add_metadata: true,
        fields: [:id, :name, :data]
      ).to_json.should == json_data
    end

    it 'returns not all field, whithout metadata' do
      json_data = {master: {id: 1, name: 'Object1'}}.to_json

      MasterSerializer.new(
        @object,
        add_metadata: false,
        fields: [:id, :name]
      ).to_json.should == json_data
    end

    it 'returns not all field, whithout metadata if serializer does not respond to meta method' do
      json_data = {master: {id: 1, name: 'Object1'}}.to_json

      MasterSerializer.any_instance.stub(:respond_to?).with(:meta).and_return(false)

      MasterSerializer.new(
        @object,
        fields: [:id, :name]
      ).to_json.should == json_data
    end

    it 'returns all field with slaves' do
      json_data = {master: {id: 1, name: 'Object1', data: '123',
        slaves: [
          {slave: {id: 1, name: 'Slave 1', data: nil}},
          {slave: {id: 2, name: 'Slave 2', data: nil}},
        ]}}.to_json

      MasterSerializer.new(
        @object,
        add_metadata: false,
        fields: [:id, :name, :data, :slaves]
      ).to_json.should == json_data
    end
  end
end
