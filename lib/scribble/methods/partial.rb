module Scribble
  module Methods
    class Partial < Method
      register :partial, String, [Object, 1]

      def partial name, object = nil
        @context.template.load(name, @context).tap do |partial_context|
          raise Errors::NotFound.new("Partial '#{name}' not found #{@call.line_and_column}") if partial_context.nil?
          partial_context.set_variable name.to_sym, object if object
        end.render
      end
    end
  end
end
