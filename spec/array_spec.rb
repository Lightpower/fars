require 'spec_helper'

describe Array do
  subject { %w{green blue grey} }
  let(:json_data) { { colors: [{ color: 'green' }, { color: 'blue' }, { color: 'grey' }] }.to_json }

  specify 'serialize with proc' do
    subject.serialize(root_key: :colors,
      serializer: Proc.new { |c| { color: c } }).should == json_data
  end

  specify 'serialize with block' do
    subject.serialize(root_key: :colors) { |c| { color: c } }.should == json_data
  end

  specify 'serialize with custom class' do
    subject.serialize(root_key: :colors, serializer: 'ColorSerializer').should == json_data
  end
end
