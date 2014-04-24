require 'spec_helper'

describe 'Array#serialize' do
  subject { %w{green blue grey} }
  let(:json_data) { { colors: [{ color: 'green' }, { color: 'blue' }, { color: 'grey' }] }.to_json }

  specify 'with proc as item serializer' do
    subject.serialize(root_key: :colors,
      serializer: Proc.new { |c| { color: c } }).should == json_data
  end

  specify 'with block as item serializer' do
    subject.serialize(root_key: :colors) { |c| { color: c } }.should == json_data
  end

  specify 'with custom class as item serializer' do
    subject.serialize(root_key: :colors, serializer: 'ColorSerializer').should == json_data
  end
end
