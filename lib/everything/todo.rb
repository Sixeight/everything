# -*- coding: utf-8 -*-

module Everything

  class Todo < ThingsObject

    module STATUS
      INCOMPLETED = 0
      CANCELED    = 2
      COMPLETED   = 3
    end.freeze

    def initialize(*args)
      super(*args)
      self.class.__send__(:add_todo, self)
    end

    def incompleted?
      status == STATUS::INCOMPLETED
    end

    def completed?
      status == STATUS::COMPLETED
    end

    def canceled?
      status == STATUS::CANCELED
    end

    module ClassMethods

      def self.extended(base)
        base.class_eval do
          @todos = []
        end
      end

      def find(id)
        core.todos(true)
        @todos.find {|todo| todo.id == id }
      end

      private
      def add_todo(todo)
        @todos << todo
      end
    end
    extend ClassMethods
  end
end

