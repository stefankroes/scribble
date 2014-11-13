module Scribble
  class Template < Partial

    def initialize source, format: nil, loader: nil, converters: []
      super source, format: format
      @loader, @converters = loader, converters
    end

    # Template context

    class Context < Partial::Context
      def initialize template, registers, variables, render_format
        @template, @registers, @variables, @render_format = template, registers, variables, render_format
      end

      def nodes
        @template.nodes
      end

      def template
        @template
      end

      def registers
        @registers
      end

      def format
        @template.format
      end

      def render_format
        @render_format
      end
    end

    # Render

    def render variables: {}, registers: {}, format: nil
      Context.new(self, registers, variables, format).render
    end

    # Load partial

    def load name, context
      if @loader
        if partial = @loader.load(name)
          Partial::Context.new partial, context
        end
      else
        raise 'Cannot load partial without loader'
      end
    end

    # Find converter

    def find_converter from, to
      @converters.find { |converter| converter.from == from && converter.to == to }
    end
  end
end
