# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'

module Everything

  describe Focus do

    before(:all) do
      @doc = Nokogiri::XML.parse(<<-EOS).xpath('//object').first
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
      @core = mock('core', :null_object => true)
      Focus.with(@core)
      @focus = Focus.new(@doc)
    end

    subject { @focus }

    its :focustype do
      should == 1
    end

    its :id do
      should == 'z110'
    end

    its :focuslevel do
      should == 0
    end

    its :display do
      should == true
    end

    its :index do
      should == 0
    end

    its :name do
      should == 'FocusInbox'
    end

    # TODO: need relationship test

    it "can list today's task" do
      Focus.with(Core.new(
        File.dirname(__FILE__) + '/database_dummy.xml'))
      todos = Focus.find(:today).todos
      todos.should have(1).task
      todos[0].id.should == 'z145'
    end

    it 'can and search with tag' do
      pending 'need more dummy database or mock'
      @focus.tag(:Home).first.id.should == 'z144'
    end

    it 'can enumerate todos' do
      Tag.stub(:find => mock('todo', :id => 'z144'))
      @focus.each do |todo|
        todo.id.should == 'z144'
      end
    end

    it 'has enumerable methods' do
      Enumerable.instance_methods.each do |meth|
        @focus.should respond_to meth
      end
    end

    describe Focus::ClassMethods do

      it 'adds self to focuses' do
        lambda {
          Focus.new(@doc)
        }.should change {
          Focus.instance_variable_get(:@focuses).length
        }.by(1)
      end

      it 'calls core focuses method when find is called' do
        @core.should_receive(:focuses)
        Focus.find(:inbox)
      end

      it 'can find focus' do
        Focus.__send__(:add_focus, @focus)
        inbox = Focus.find :inbox
        inbox.name.should == 'FocusInbox'
        inbox.id.should == 'z110'
        inbox.focustype.should == 1
      end

      it 'can find focus (not found)' do
        Focus.instance_variable_set :@focuses, []
        inbox = Focus.find :inbox
        inbox.should be_nil
      end

      it 'can get certain focus name' do
        [
          %w[ inbox     FocusInbox ],
          %w[ someday   FocusMaybe ],
          %w[ later     FocusMaybe ],
          %w[ today     FocusToday ],
          %w[ Today     FocusToday ],
          %w[ next      FocusNextActions ],
          %w[ Next      FocusNextActions ],
          %w[ scheduled FocusTickler ],
          %w[ Scheduled FocusTickler ],
          %w[ logbook   FocusLogbook ],
          %w[ Logbook   FocusLogbook ],
          %w[ LogBook   FocusLogbook ],
          %w[ trash     FocusTrash ],
          %w[ projects  FocusActivityLevel-1 ],
          %w[ projects  FocusActivityLevel-1 ],
          %w[ areas     FocusActivityLevel-2 ],
          %w[ Areas     FocusActivityLevel-2 ],
        ].each do |nick, certain|
          Focus.normalize(nick).should == certain
        end
      end
    end
  end
end

