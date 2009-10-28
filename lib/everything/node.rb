# -*- coding: utf-8 -*-

require 'rubygems'
require 'nokogiri'

class ThingsObject

  def initialize(doc)
    @doc = doc
  end

  def id
    @doc['id']
  end

  def type
    @doc['type']
  end

  def attribute(name)
    query = %|//attribute[@name="#{name}"]|
    if attribute = @doc.xpath(query)
      return attribute.first
    end
    nil
  end

  def relationship(name)
    query = %|//relationship[@name="#{name}"]|
    if relationship = @doc.xpath(query)
      return relationship.first
    end
    nil
  end
end

