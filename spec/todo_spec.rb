# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'

module Everything

  describe Todo do

    before(:all) do
      @doc = Nokogiri::XML.parse(<<-EOS).xpath('//object').first
        <object type="TODO" id="z144">
            <attribute name="todayoffset" type="float">3</attribute>
            <attribute name="status" type="int32">0</attribute>
            <attribute name="focustype" type="int32">1</attribute>
            <attribute name="focuslevel" type="int16">0</attribute>
            <attribute name="datemodified" type="date">274201500.83986997604370117188</attribute>
            <attribute name="datecreated" type="date">273506483.01396399736404418945</attribute>
            <attribute name="title" type="string">Everythingsを公開する</attribute>
            <attribute name="index" type="int32">15</attribute>
            <attribute name="identifier" type="string">4099F3F0-A53E-4F9D-A0EE-5C54DB2E5968</attribute>
            <attribute name="compact" type="bool">1</attribute>
            <relationship name="parent" type="1/1" destination="THING"></relationship>
            <relationship name="author" type="1/1" destination="COWORKER"></relationship>
            <relationship name="delegate" type="1/1" destination="COWORKER"></relationship>
            <relationship name="focus" type="1/1" destination="FOCUS" idrefs="z124"></relationship>
            <relationship name="recurrenceinstance" type="1/1" destination="TODO"></relationship>
            <relationship name="recurrencetemplate" type="1/1" destination="TODO"></relationship>
            <relationship name="scheduler" type="1/1" destination="GLOBALS"></relationship>
            <relationship name="syncdata" type="1/1" destination="SYNCEDTASK"></relationship>
            <relationship name="children" type="0/0" destination="THING"></relationship>
            <relationship name="tags" type="0/0" destination="TAG" idrefs="z102"></relationship>
            <relationship name="reminderdates" type="0/0" destination="REMINDER"></relationship>
        </object>
      EOS
      @core = mock('core', :null_object => true)
      Todo.with(@core)
      (class << Todo; self end).instance_variable_set(:@todos, [])
      @todo = Todo.new(@doc)
    end

    subject { @todo }

    its :todayoffset do
      should == 3
    end

    its :status do
      should ==0
    end

    its :focustype do
      should == 1
    end

    its :focuslevel do
      should == 0
    end

    its :datemodified do
      pending 'date'
      should == '274201500.83986997604370117188'
    end

    its :datecreated do
      pending 'date'
      should == '273506483.01396399736404418945'
    end

    its :title do
      should == 'Everythingsを公開する'
    end

    its :index do
      should == 15
    end

    its :identifier do
      should == '4099F3F0-A53E-4F9D-A0EE-5C54DB2E5968'
    end

    its :compact do
      should == true
    end

    # TODO: need relationship test

    its :incompleted? do
      should == true
    end

    its :completed? do
      should == false
    end

    its :canceled? do
      should == false
    end

    describe Todo::ClassMethods do

      it 'adds self to focuses' do
        lambda {
          Todo.new(@doc)
        }.should change {
          Todo.instance_variable_get(:@todos).length
        }.by(1)
      end

      it 'calls core focuses method when find is called' do
        @core.should_receive(:todos).with(true)
        Todo.find('z144')
      end

      it 'can find todo' do
        Todo.__send__(:add_todo, @todo)
        todo = Todo.find 'z144'
        todo.id.should == 'z144'
        todo.identifier.should == '4099F3F0-A53E-4F9D-A0EE-5C54DB2E5968'
        todo.title.should == 'Everythingsを公開する'
      end

      it 'can find todo (not found)' do
        Todo.instance_variable_set :@todos, []
        todo = Todo.find 'z180'
        todo.should be_nil
      end
    end
  end
end

