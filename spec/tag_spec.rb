# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'

module Everything

  describe Tag do

    before(:all) do
      @doc = Nokogiri::XML.parse(<<-EOS).xpath('//object').first
        <object type="TAG" id="z102">
            <attribute name="dateused" type="date">273512152.85076302289962768555</attribute>
            <attribute name="type" type="int32">0</attribute>
            <attribute name="shortcut" type="string">h</attribute>
            <attribute name="title" type="string">Home</attribute>
            <attribute name="index" type="int32">15</attribute>
            <attribute name="identifier" type="string">CC-Things-Tag-Home</attribute>
            <relationship name="parent" type="1/1" destination="THING" idrefs="z119"></relationship>
            <relationship name="record" type="1/1" destination="RECORD"></relationship>
            <relationship name="children" type="0/0" destination="THING"></relationship>
            <relationship name="notes" type="0/0" destination="NOTE" idrefs="z144"></relationship>
        </object>
      EOS
      @core = mock('core', :null_object => true)
      Tag.with(@core)
      @tag = Tag.new(@doc)
    end

    subject { @tag }

    its :type do
      should == 0
    end

    its :dateused do
      pending 'date'
      should == '273512152.85076302289962768555'
    end

    its :shortcut do
      should == 'h'
    end

    its :title do
      should == 'Home'
    end

    its :index do
      should == 15
    end

    its :identifier do
      should == 'CC-Things-Tag-Home'
    end

    # TODO: need relationship test

    it 'can list todos' do
      @tag.should respond_to(:todos)
    end

    it 'can enumerate todos' do
      Todo.stub(:find => mock('todo', :id => 'z144'))
      @tag.each do |todo|
        todo.id.should == 'z144'
      end
    end

    it 'has enumerable methods' do
      Enumerable.instance_methods.each do |meth|
        @tag.should respond_to meth
      end
    end

    it 'has simple information to show itself' do
      @tag.inspect.should == "#<Everything::Tag #{@tag.__id__} 'Home'>"
    end

    describe Tag::ClassMethods do

      it 'adds self to tag' do
        lambda {
          Tag.new(@doc)
        }.should change {
          Tag.instance_variable_get(:@tags).length
        }.by(1)
      end

      it 'calls core focuses method when find is called' do
        Tag.core.should_receive(:tags)
        Tag.find(:Home)
      end

      it 'can find tag (with name)' do
        Tag.instance_variable_set :@tags, [@tag]
        home = Tag.find :Home
        home.title.should == 'Home'
        home.identifier.should == 'CC-Things-Tag-Home'
      end

      it 'can find tag (with id)' do
        Tag.instance_variable_set :@tags, [@tag]
        home = Tag.find 'z102'
        home.title.should == 'Home'
        home.identifier.should == 'CC-Things-Tag-Home'
      end

      it 'can find tag (not found)' do
        Tag.instance_variable_set :@tags, []
        home = Tag.find :Home
        home.should be_nil
      end
    end
  end
end

