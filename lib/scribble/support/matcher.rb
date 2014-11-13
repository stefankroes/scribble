module Scribble
  module Support
    class Matcher
      def initialize registry, name, receiver, args
        @registry, @name, @receiver, @args = registry, name, receiver, args
      end

      # Name and receiver matching

      def base_matches
        @base_matches ||= @registry.methods.select do |method|
          method.method_name == @name && @receiver.is_a?(method.receiver_class)
        end
      end

      # Args cursor helpers

      def step_arg arg_class
        @cursor += 1 if @cursor < @args.size && @args[@cursor].is_a?(arg_class)
      end

      def step_args arg_class, max = nil
        index = 0; while index += 1
          break unless step_arg arg_class
          break if max && index == max
        end
      end

      # Argument expectations

      def expect arg_class
        if @max_cursor.nil? || @cursor > @max_cursor
          @expected, @max_cursor = [], @cursor
        end
        if arg_class && @cursor == @max_cursor
          @expected << @registry.class_name(arg_class)
        end
      end

      def unexpected
        if @max_cursor && @max_cursor < @args.size
          @registry.class_name @args[@max_cursor].class
        end
      end

      # Match a single method

      def match_args method
        @cursor = 0
        method.signature.each do |element|
          if element.is_a? Array
            step_args *element
          elsif !step_arg element
            expect element; return false
          end
        end
        if @cursor < @args.size
          expect nil; return false
        end
        method
      end

      # Get first match

      def match
        @match ||= base_matches.select do |method|
          @args.size >= method.min_arity && (method.max_arity.nil? || @args.size <= method.max_arity)
        end.select do |method|
          match_args method
        end.first || raise(Unmatched.new @base_matches, @expected || [], unexpected, @max_cursor)
      end
    end
  end
end
