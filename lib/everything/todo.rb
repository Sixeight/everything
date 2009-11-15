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
      is_now? :incompleted
    end

    def completed?
      is_now? :completed
    end

    def canceled?
      is_now? :canceled
    end

    # FIXME: exception needs to move into base class
    def is_now?(state)
      status == STATUS.const_get(state.to_s.upcase)
    rescue
      false
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

