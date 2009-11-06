# -*- coding: utf-8 -*-

module Everything

  class Tag < ThingsObject

    def initialize(*args)
      super(*args)
      self.class.__send__(:add_tag, self)
    end

    def todos
      notes
    end

    def each
      todos.each do |todo|
        yield todo
      end
    end

    module ClassMethods

      def self.extended(base)
        base.class_eval do
          @tags = []
        end
      end

      def find(name_or_id)
        core.tags
        @tags.find {|tag|
          tag.title == name_or_id.to_s or
             tag.id == name_or_id
        }
      end

      private
      def add_tag(focus)
        @tags << focus
      end
    end
    extend ClassMethods
  end
end

