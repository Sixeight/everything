# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'

module Everything
  describe ThingsObject do
    before do
      @doc = Nokogiri::XML.parse(<<-EOS).xpath('//object').first
        <object type="FOCUS" id="z110">
            <attribute name="focustype" type="int32">1</attribute>
            <attribute name="focuslevel" type="int16">0</attribute>
            <attribute name="display" type="bool">1</attribute>
            <attribute name="index" type="int32">0</attribute>
            <attribute name="identifier" type="string">\\u11ffFocusInbox</attribute>
            <relationship name="parent" type="1/1" destination="THING" idrefs="z120"></relationship>
            <relationship name="children" type="0/0" destination="THING"></relationship>
            <relationship name="focustodos" type="0/0" destination="TODO" idrefs="z144"></relationship>
            <relationship name="notes" type="0/0" destination="NOTE" idrefs="z144"></relationship>
        </object>
      EOS
      @object = ThingsObject.new(@doc)
    end

    it 'undef exist method' do
      class ThingsObject; def display; end end
      ThingsObject.should_receive(:undef_method).with('display')
      ThingsObject.new(@doc)
    end

    it 'has core' do
      ThingsObject.with(nil)
      @object.class.should respond_to(:core)
      @object.class.core.should be_nil
      core = mock('core')
      ThingsObject.with(core)
      @object.class.core.should equal(core)
    end

    subject { @object }

    it 'can take id and type' do
      @object.id.should == 'z110'
      @object.object_type.should == 'FOCUS'
    end
    its(:id) { should == 'z110' }
    its(:object_type) { should == 'FOCUS' }

    it 'can take attribute by name (int32)' do
      @object.attribute('focustype').should == 1
    end
    its(:focustype) { should == 1 }

    it 'can take attribute by name (int16)' do
      @object.attribute('focuslevel').should == 0
    end
    its(:focuslevel) { should == 0 }

    it 'can take attribute by name (bool)' do
       @object.attribute('display').should be_true
    end
    its(:display) { should be_true }

    it 'can take attribute by name (string)' do
      @object.attribute('identifier').should == '１FocusInbox'
    end
    its(:identifier) { should == '１FocusInbox' }

    it 'returns nil when take invalid name' do
      @object.attribute('hoge').should be_nil
    end
    it { lambda { @object.hoge }.should raise_error(NoMethodError)  }

    it 'can take relationship by name' do
      Todo.stub(:find => :todo)
      todo = @object.relationship('focustodos')
      todo.should == [:todo]
    end

    it 'can take relationship by name (same class)' do
      ThingsObject.stub(:find => :thing)
      todo = @object.relationship(:parent)
      todo.should == :thing
    end

    it 'can take relationship by name (Notes)' do
      Todo.stub(:find => :notes)
      todo = @object.relationship(:notes)
      todo.should == [:notes]
    end

    it 'can take relationship by name (correct amount)' do
      Todo.stub(:find => :amount)
      @object.relationship(:focustodos).should be_an_instance_of(Array)
      ThingsObject.stub(:find => :amount)
      @object.relationship(:parent).should_not be_an_instance_of(Array)
    end

    it 'returns nil when take invalid name' do
      @object.relationship('hoge').should be_nil
    end

    it 'has simple information to show itself' do
      @object.inspect.should == "#<Everything::ThingsObject #{@object.__id__}>"
    end

    subject { @object }
    its :parent? do
      should == false
    end
  end
end

