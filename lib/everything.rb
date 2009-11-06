# -*- coding: utf-8 -*-

require 'rubygems'
require 'nokogiri'

$:.unshift File.dirname(__FILE__)
require 'everything/things_object'
require 'everything/focus'
require 'everything/todo'
require 'everything/tag'

module Everything

  DEFAULT_DATABASE_PATH = ENV['HOME'] + '/Library/Application Support/Cultured Code/Things/Database.xml'

  def new(path = DEFAULT_DATABASE_PATH)
    core = Core.new(path)
    yield core if block_given?
    core
  end
  module_function :new

  class Core

    attr_reader :path

    def initialize(path)
      @path = path
      Focus.with(self)
      Todo.with(self)
      Tag.with(self)
    end

    def focuses
      @focuses ||= doc.xpath('//object[@type="FOCUS"]').map {|focus|
        Focus.new(focus)
      }.sort_by(&:id)
    end

    def focus(name_or_id)
      focuses if @focuses.nil?
      Focus.find(name_or_id)
    end

    def todos(parent = false)
      @todos ||= doc.xpath('//object[@type="TODO"]').map {|todo|
        Todo.new(todo)
      }.sort_by(&:id)
      return @todos.reject(&:parent?) unless parent
      @todos
    end

    def tags
      @tags ||= doc.xpath('//object[@type="TAG"]').map {|tag|
        Tag.new(tag)
      }.sort_by(&:id)
    end

    def tag(name)
      Tag.find(name)
    end

    def projects
      focus(:projects).todos
    end

    def areas
      focus(:areas).todos
    end

    private

    def parse
      @doc || parse!
    end

    def parse!
      @doc = Nokogiri::XML.parse(File.read(@path))
    end

    def doc
      parse
    end
  end
end

