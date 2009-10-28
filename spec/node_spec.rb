# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../lib/everything/node'

describe ThingsObject do
  before do
    @doc = <<-EOS
      <object type="FOCUS" id="z110">
          <attribute name="focustype" type="int32">1</attribute>
          <attribute name="focuslevel" type="int16">0</attribute>
          <attribute name="display" type="bool">1</attribute>
          <attribute name="index" type="int32">0</attribute>
          <attribute name="identifier" type="string">FocusInbox</attribute>
          <relationship name="parent" type="1/1" destination="THING" idrefs="z120"></relationship>
          <relationship name="children" type="0/0" destination="THING"></relationship>
          <relationship name="focustodos" type="0/0" destination="TODO" idrefs="z144"></relationship>
      </object>
    EOS
    objects = Nokogiri::XML.parse(@doc).xpath('object')
    @object = ThingsObject.new(objects.first)
  end

  it 'can take id and type' do
    @object.id.should == 'z110'
    @object.type.should == 'FOCUS'
  end

  it 'can take attribute by name' do
    attribute = @object.attribute('focustype')
    attribute.content.should == '1'
    attribute['type'].should == 'int32'
  end

  it 'returns nil when take invalid name' do
    @object.attribute('hoge').should be_nil
  end

  it 'can take relationship by name' do
    relationship = @object.relationship('focustodos')
    relationship.content.should be_empty
    relationship['type'].should == '0/0'
    relationship['destination'].should == 'TODO'
    relationship['idrefs'].should == 'z144'
  end

  it 'returns nil when take invalid name' do
    @object.relationship('hoge').should be_nil
  end
end

