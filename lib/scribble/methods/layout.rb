module Scribble
  module Methods
    class Layout < Block
      register :layout, String, [Object, 1]

      def layout name, object = nil
        template.load(name, self).tap do |partial_context|
          raise Errors::NotFound.new("Layout partial '#{name}' not found #{@call.line_and_column}") if partial_context.nil?
          partial_context.set_variable name.to_sym, object if object
          @render_format = partial_context.format
        end.render
      end

      method :content

      def content
        render context: @context
      end

      def render_format
        @render_format || super
      end
    end
  end
end
