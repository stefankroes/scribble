module Scribble
  def self.converter from_to, &block
    Object.new.tap do |converter|
      converter.define_singleton_method(:from) { from_to.keys.first }
      converter.define_singleton_method(:to)   { from_to.values.first }

      converter.define_singleton_method :convert, &block
    end
  end
end
