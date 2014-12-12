module Scribble
  module Nodes
    class Call < Node
      attr_reader :name, :args, :allow_variable

      attr_accessor :receiver, :nodes

      def initialize slice, name, args: [], receiver: nil, allow_variable: false
        super slice
        @name, @args, @receiver, @allow_variable = name, args, receiver, allow_variable
      end

      def evaluate context, allow_block: true, allow_split: false
        disallow_split unless allow_split
        disallow_block unless allow_block

        if @receiver
          Registry.evaluate @name, evaluated_receiver(context), evaluated_args(context), self, context
        else
          context.evaluate self, evaluated_args(context), context
        end
      rescue Errors::UnlocatedArgument => e
        raise Errors::Argument.new("#{e.message} #{line_and_column}")
      rescue Support::Unmatched => e
        raise e.to_error self
      end

      def block?
        Registry.block? name
      end

      def split?
        Registry.split? name
      end

    private

      def disallow_split
        raise Errors::Syntax.new "Unexpected '#{name}' #{line_and_column}" if split?
      end

      def disallow_block
        raise Errors::Syntax.new "Unexpected '#{name}' #{line_and_column}; block methods can't be arguments" if block?
      end

      def evaluated_receiver context
        @receiver.evaluate context, allow_block: false
      end

      def evaluated_args context
        args.map { |arg| arg.evaluate context, allow_block: false }
      end
    end
  end
end
