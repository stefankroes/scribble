module Scribble
  module Support
    module Context

      # Registry method shortcut

      module ClassMethods
        def method *args
          Scribble::Registry.for(self) { method *args }
        end
      end

      def self.included base
        base.extend ClassMethods
      end

      # Rendering

      def nodes
        raise NotImplementedError, 'Class that includes context must implement nodes method'
      end

      def render nodes: nil, context: self
        nodes ||= self.nodes
        
        if !require_conversion?
          render_without_conversion nodes, context

        elsif converter
          converter.convert render_without_conversion(nodes, context)

        elsif format.nil?
          raise "Cannot convert to #{render_format} without format"
        else
          raise "No suitable converter converting #{format} to #{render_format}"
        end
      end

      def render_without_conversion nodes, context
        nodes.map { |node| Scribble::Registry.to_string node.evaluate(context) }.join
      end

      # Template and registers

      def template
        @context.template
      end

      def registers
        @context.registers
      end

      # Format conversion

      def format
        @context.format
      end

      def render_format
        @context.format
      end

      def require_conversion?
        render_format && format != render_format
      end

      def converter
        @converter ||= template.find_converter(format, render_format)
      end

      # Variables

      def variables
        @variables ||= {}
      end

      def set_variable name, value
        variables[name] = value
      end

      def resolve_variable call
        variables[call.name] if call.allow_variable
      end

      # Evaluation

      def evaluate call, args, context
        resolve_variable(call) || Scribble::Registry.evaluate(call.name, self, args, call, context)
      rescue Support::Unmatched => local
        raise local if @context.nil? || call.split?

        begin
          @context.evaluate call, args, context
        rescue Support::Unmatched => global
          raise global.merge(local)
        end
      end
    end
  end
end
