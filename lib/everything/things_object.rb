# -*- coding: utf-8 -*-

module Everything
  class ThingsObject

    TypeTable = {
      'int32'  => 'Integer',
      'int16'  => 'Integer',
      'float'  => 'Float',
      'string' => 'String',
      'bool'   => 'truth',
    }

    def truth(value)
      value == '1' ? true : false
    end
    private :truth

    def self.with(core)
      @@core = core
    end

    def self.core
      if defined? @@core
        @@core
      end
    end

    def initialize(doc)
      @doc  = doc
      %w[ relationship attribute ].each do |name|
        names = @doc.xpath(name).map {|e| e['name'] }
        instance_variable_set :"@#{name}s", names
      end
      undef_methods
    end

    def id
      @doc['id']
    end

    def object_type
      @doc['type']
    end

    def parent?
      !!children
    end

    def attribute(name)
      query = %|attribute[@name="#{name}"]|
      if attributes = @doc.xpath(query)
         if attribute = attributes.first
           filter = method(TypeTable[attribute['type']])
           return filter.call(decode_unicode_number(attribute.content))
         end
      end
      nil
    end

    def relationship(name)
      query = %|relationship[@name="#{name}"]|
      if relationships = @doc.xpath(query)
        if relationship = relationships.first
          klass = relationship['destination'].capitalize
          ids   = relationship['idrefs']
          unless ids.empty?
            target = thing(klass)
            result = ids.split.map {|id|
              target.find(id)
            }.compact
            if relationship['type'] == '1/1'
              result = result.first
            end
            return result
          end
        end
      end
      nil
    rescue NameError
      nil
    end

    def method_missing(meth, *args)
      if @attributes.include?(meth.to_s)
        if value = attribute(meth)
          return value
        end
        return nil
      end
      if @relationships.include?(meth.to_s)
        if relations = relationship(meth)
          return relations
        end
        return nil
      end
      super
    end

    def inspect
      "#<#{self.class} #{__id__}>"
    end

    private
    def undef_methods
      all_methods = self.class.instance_methods
      @attributes.each do |target|
        if all_methods.include? target
          self.class.__send__(:undef_method, target)
        end
      end
    end

    def thing(klass)
      if klass == 'Thing'
        return self.class
      end
      klass = 'Todo' if klass == 'Note'
      Everything.const_get(klass)
    end

    def decode_unicode_number(num)
      num.gsub(/\\u1(\d)ff/) do
        case $1
        when '0' then '０'
        when '1' then '１'
        when '2' then '２'
        when '3' then '３'
        when '4' then '４'
        when '5' then '５'
        when '6' then '６'
        when '7' then '７'
        when '8' then '８'
        when '9' then '９'
        end
      end
    end
  end
end

