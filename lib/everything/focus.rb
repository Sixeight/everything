# -*- coding: utf-8 -*-

module Everything

  class Focus < ThingsObject

    include Enumerable

    def initialize(*args)
      super(*args)
      self.class.__send__(:add_focus, self)
    end

    def method_missing(meth, *args)
      target = meth == :name ? :identifier : meth
      super(target, *args)
    end

    def todos
      # FIXME: dirty hack
      if name == 'FocusToday'
        unless Focus.core.nil?
          return Focus.core.todos.select {|todo|
            todo.focustype == focustype }
        end
      end
      focustodos
    end

    def tag(name)
      tag = Tag.find(name)
      todos.select {|t| t.tags && t.tags.include?(tag) }
    end

    def each
      todos.each do |todo|
        yield todo
      end
    end

    def inspect
      "#<#{self.class} #{__id__} '#{identifier}'>"
    end

    module ClassMethods

      VALID_NAME_PATTERN = /\AFocus(?:[A-Z].+)+\z/

      def self.extended(base)
        base.class_eval do
          @focuses = []
        end
      end

      def find(name_or_id)
        core.focuses
        if name_or_id.instance_of?(Integer)
          return @focuses.find {|focus| focus.focustype == name_or_id }
        end
        @focuses.find {|focus|
          focus.name == normalize(name_or_id) or
            focus.id == name_or_id
        }
      end

      def normalize(name)
        name = name.to_s
        return name if valid_name?(name)
        'Focus' << case name
          when /next/i      then 'NextActions'
          when /someday/i   then 'Maybe'
          when /later/i     then 'Maybe'
          when /scheduled/i then 'Tickler'
          when /projects/i  then 'ActivityLevel-1'
          when /areas/i     then 'ActivityLevel-2'
          else name.capitalize
        end
      end

      def valid_name?(name)
        !!(VALID_NAME_PATTERN =~ name)
      end

      private
      def add_focus(focus)
        @focuses << focus
      end
    end
    extend ClassMethods
  end
end

