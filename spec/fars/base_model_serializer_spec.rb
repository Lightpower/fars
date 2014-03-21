require 'spec_helper'

describe Fars::BaseModelSerializer do
  before :all do
    class Master < ActiveRecord::Base
      has_many :slaves
    end
  end

  context '#to_json' do
    before :each do
      @object = Master.create(id: 1, name: 'Object1', data: '123')
      @json = {id: 1, name: 'Object1', data: '123'}.to_json
    end

    it 'represent as json' do
      @object.to_json.should == @json
    end
  end

end
