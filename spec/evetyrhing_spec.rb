# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../lib/everything'

describe Everything do

  before(:all) do
    @database = File.dirname(__FILE__) + '/database_dummy.xml'
  end

  it 'can set default database path' do
    Everything.new.path.should == Everything::DEFAULT_DATABASE_PATH
  end

  it 'can list all todos' do
    $stdout, old_strout = StringIO.new, $stdout
    Everything.new(@database) do |things|
      things.todos.each do |t|
        status = t.completed? ? '+' : t.canceled? ? 'x' : '-'
        puts "#{status} : #{t.title}"
      end
    end
    expect = "- : Everythingsを公開する\n+ : Everythingsの開発を進める\nx : Everythingsのテストを充実させる\n"
    $stdout.rewind
    $stdout.read.should == expect
    $stdout = old_strout
  end

  it 'can get inbox tasks' do
    $stdout, old_strout = StringIO.new, $stdout
    Everything.new(@database) do |things|
      things.focus(:inbox).todos.each do |todo|
        status = case todo.status
        when 0 then '-'
        when 2 then 'x'
        when 3 then '+'
        end
        puts "[#{status}] #{todo.title}"
      end
    end
    expect = "[-] Everythingsを公開する\n"
    $stdout.rewind
    $stdout.read.should == expect
    $stdout = old_strout
  end

  describe Everything::Core do

    before do
      @core = Everything::Core.new(@database)
    end

    subject { @core }

    its :path do
      should == @database
    end

    it 'can parse database' do
      @core.should_receive(:parse!)
      @core.__send__(:doc)
    end

    it 'has parsed doc' do
      @core.instance_variable_get(:@doc).should be_nil
      @core.__send__(:doc)
      @core.instance_variable_get(:@doc).should_not be_nil
    end

    it 'can cache doc' do
      @core.__send__(:doc)
      old = @core.instance_variable_get(:@doc)
      @core.__send__(:doc)
      @core.instance_variable_get(:@doc).should equal(old)
    end

    it 'can clear doc cache' do
      @core.__send__(:doc)
      old = @core.instance_variable_get(:@doc)
      @core.__send__(:parse!)
      @core.instance_variable_get(:@doc).should_not equal(old)
    end

    describe 'focus' do

      it 'can list all focus' do
        focuses = @core.focuses
        focuses.map(&:name).should ==
          %w[FocusInbox FocusMaybe FocusToday FocusNextActions
            FocusTickler FocusLogbook FocusTrash FocusActivityLevel-1 FocusActivityLevel-2]
        focuses.map(&:id).should == %w[z110 z111 z112 z113 z114 z115 z116 z193 z194]
      end

      it 'can find focus by name' do
        focus = @core.focus(:inbox)
        focus.name.should == 'FocusInbox'
      end

      it 'can find focus by id' do
        focus = @core.focus('z111')
        focus.name.should == 'FocusMaybe'
      end

      it 'has todos' do
        focus = @core.focus(:inbox)
        focus.todos.first.id.should == 'z144'
      end

      it 'can and search with tag' do
        todos = @core.focus(:inbox).tag(:Home)
        todos.first.id.should == 'z144'
      end
    end

    describe 'todo' do

      it 'can list all todos' do
        todos = @core.todos(true)
        todos.map(&:id).should == %w[ z144 z145 z146 z147 ]
        todos.should have(4).todos
      end

      it 'can list not parent todos' do
        todos = @core.todos
        todos.map(&:id).should == %w[ z144 z145 z146 ]
        todos.should have(3).todos
      end

      it 'has tags' do
        todo = Everything::Todo.find('z144')
        todo.tags.first.id.should == 'z102'
      end
    end

    describe 'tag' do

      it 'can list all tags' do
        tags = @core.tags
        tags.map(&:id).should == %w[ z102 z103 z104 ]
      end

      it 'can search tag by name' do
        tag = @core.tag(:Home)
        tag.title.should == 'Home'
      end
    end

    describe 'projects' do

      it 'can list projects' do
        projects = @core.projects
        projects.first.id.should == 'z147'
      end
    end

    describe 'areas' do

      it 'can list areas' do
        areas = @core.areas
        areas.first.id.should == 'z147'
      end
    end
  end
end

